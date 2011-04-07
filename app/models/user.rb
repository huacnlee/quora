# coding: utf-8
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Voter
  include BaseModel
  
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  field :name
  field :slug
  field :tagline
  field :bio
  field :avatar
  field :website
  # 是否是女人
  field :girl, :type => Boolean, :default => false
  # 软删除标记，1 表示已经删除
  field :deleted, :type => Integer

  # 不感兴趣的问题
  field :muted_ask_ids, :type => Array, :default => []
  # 关注的问题
  field :followed_ask_ids, :type => Array, :default => []
  # 回答过的问题
  field :answered_ask_ids, :type => Array, :default => []

  # 邀请字段
  field :invitation_token
  field :invitation_sent_at, :type => DateTime

  field :asks_count, :type => Integer, :default => 0
  has_many :asks

  field :answers_count, :type => Integer, :default => 0
  has_many :answers

  references_and_referenced_in_many :followed_asks, :stored_as => :array, :inverse_of => :followers, :class_name => "Ask"
  references_and_referenced_in_many :followed_topics, :stored_as => :array, :inverse_of => :followers, :class_name => "Topic"
  
  references_and_referenced_in_many :following, :class_name => 'User', :inverse_of => :followers, :index => true, :stored_as => :array
  references_and_referenced_in_many :followers, :class_name => 'User', :inverse_of => :following, :index => true, :stored_as => :array

  embeds_many :authorizations
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"

  attr_accessor  :password_confirmation
  attr_accessible :email, :password,:name, :slug, :tagline, :bio, :avatar, :website, :girl

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /[a-z0-9\-\_]+/i

  # 以下两个方法是给 redis search index 用
  def avatar_small
    self.avatar.small.url
  end
  def avatar_small_changed?
    self.avatar_changed?
  end
  redis_search_index(:title_field => :name, :ext_fields => [:slug,:avatar_small,:tagline])

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("tagline")
      return false
    end
    if self.spam?("name")
      return false
    end
    if self.spam?("slug")
      return false
    end
    if self.spam?("bio")
      return false
    end
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end
  
  mount_uploader :avatar, AvatarUploader

  def self.create_from_hash(auth)  
		user = User.new
		user.name = auth["user_info"]["name"]  
		user.email = auth['user_info']['email']
    if user.email.blank?
      user.errors.add("Email","三方网站没有提供你的Email信息，无法直接注册。")
      return user
    end
		user.save
		user
  end  

  before_validation :auto_slug
  # 此方法用于处理开始注册是自动生成 slug, 因为没表单,只能自动
  def auto_slug
    if self.slug.blank?
      if !self.email.blank?
        self.slug = self.email.split("@")[0]
        self.slug = self.slug.safe_slug
      end
      # 如果 slug 被 safe_slug 后是空的,就用 id 代替
      if self.slug.blank?
        self.slug = self.id.to_s
      end
    else
      self.slug = self.slug.safe_slug
    end

    # 防止重复 slug
    old_user = User.find_by_slug(self.slug)
    if !old_user.blank? and old_user.id != self.id
      self.slug = self.id.to_s
    end
  end

  def auths
    self.authorizations.collect { |a| a.provider }
  end

  def self.find_by_slug(slug)
    first(:conditions => {:slug => slug})
  end

  # 不感兴趣问题
  def ask_muted?(ask_id)
    self.muted_ask_ids.include?(ask_id)
  end
  
  def ask_followed?(ask)
    # Rails.logger.info { "user: #{self.inspect}" }
    # Rails.logger.info { "asks: #{self.followed_asks.inspect}" }
    # Rails.logger.info { "ask: #{ask.inspect}" }
    self.followed_asks.include?(ask)
  end
  
  def followed?(user)
    self.following.include?(user)
  end
  
  def topic_followed?(topic)
    self.followed_topics.include?(topic)
  end
  
  def mute_ask(ask_id)
    self.muted_ask_ids ||= []
    return if self.muted_ask_ids.index(ask_id)
    self.muted_ask_ids << ask_id
    self.save
  end
  
  def unmute_ask(ask_id)
    self.muted_ask_ids.delete(ask_id)
    self.save
  end
  
  def follow_ask(ask)
    ask.followers << self
    ask.save
    
    insert_follow_log("FOLLOW_ASK", ask)
  end
  
  def unfollow_ask(ask)
    self.followed_asks.delete(ask)
    self.save
    
    ask.followers.delete(self)
    ask.save
    
    insert_follow_log("UNFOLLOW_ASK", ask)
  end
  
  def follow_topic(topic)
    topic.followers << self
    topic.save
    
    insert_follow_log("FOLLOW_TOPIC", topic)
  end
  
  def unfollow_topic(topic)
    self.followed_topics.delete(topic)
    self.save
    
    topic.followers.delete(self)
    topic.save
    
    insert_follow_log("UNFOLLOW_TOPIC", topic)
  end
  
  def follow(user)
    user.followers << self
    user.save

    # 发送被 Follow 的邮件
    # UserMailer.be_followed(user.id,self.id).deliver
    
    insert_follow_log("FOLLOW_USER", user)
  end
  
  def unfollow(user)
    self.following.delete(user)
    self.save
    
    user.followers.delete(self)
    user.save
    
    insert_follow_log("UNFOLLOW_USER", user)
  end

  # 软删除
  # 只是把用户信息修改了
  def soft_delete
    # assuming you have deleted_at column added already
    return false if self.deleted == 1
    self.deleted = 1
    self.name = "#{self.name}[已注销]"
    self.email = "#{self.id}@zheye.org"
    self.slug = "#{self.id}"
    self.save
  end

  protected
  
    def insert_follow_log(action, item)
      begin
        log = UserLog.new
        log.user_id = self.id
        log.title = self.name
        log.target_id = item.id
        log.action = action
        log.target_parent_id = item.id
        log.target_parent_title = item.is_a?(Ask) ? item.title : item.name
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
      
    end

end
