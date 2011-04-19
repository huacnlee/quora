# coding: utf-8
class Ask
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Sphinx
  include BaseModel
  
  field :title
  field :body
  # 最后回答时间
  field :answered_at, :type => DateTime
  field :answers_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0
  field :topics, :type => Array, :default => []
  field :spams_count, :type => Integer, :default => 0
  field :spam_voter_ids, :type => Array, :default => []
  field :views_count, :type => Integer, :default => 0
  # 最后活动时间，这个时间应该设置为该问题下辖最后一条log的发生时间
  field :last_updated_at, :type => DateTime
  # 重定向问题编号
  field :redirect_ask_id

  index :topics
  index :title

  # 提问人
  belongs_to :user, :inverse_of => :asks
  # 对指定人的提问
  belongs_to :to_user, :class_name => "User"

  # 回答
  has_many :answers
  # Log
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  # 最后个回答
  belongs_to :last_answer, :class_name => 'Answer'
  # 最后回答者
  belongs_to :last_answer_user, :class_name => 'User'
  # Followers
  references_and_referenced_in_many :followers, :stored_as => :array, :inverse_of => :followed_asks, :class_name => "User"
  # Comments
  has_many :comments, :conditions => {:commentable_type => "Ask"}, :foreign_key => "commentable_id", :class_name => "Comment"

  has_many :ask_invites

  attr_protected :user_id
  attr_accessor :current_user_id
  validates_presence_of :user_id, :title
  validates_presence_of :current_user_id, :if => proc { |obj| obj.title_changed? or obj.body_changed? }

  # 正常可显示的问题, 前台调用都带上这个过滤
  scope :normal, where(:spams_count.lt => Setting.ask_spam_max)
  scope :last_actived, desc(:answered_at)
  scope :recent, desc("created_at")
  # 除开一些 id，如用到 mute 的问题，传入用户的 muted_ask_ids
  scope :exclude_ids, lambda { |id_array| not_in("_id" => (id_array ||= [])) } 
  scope :only_ids, lambda { |id_array| any_in("_id" => (id_array ||= [])) } 
  # 问我的问题
  scope :asked_to, lambda { |to_user_id| where(:to_user_id => to_user_id) }

  # FullText indexes
  search_index(:fields => [:title,:body, :topics],
               :attributes => [],
               :options => {} )

  redis_search_index(:title_field => :title,:ext_fields => [:topics])

  before_save :fill_default_values
  after_create :create_log, :inc_counter_cache, :send_mails
  after_destroy :dec_counter_cache
  before_update :update_log

  def view!
    self.inc(:views_count, 1)
  end

  def send_mails
    # 向某人提问
    if !self.to_user.blank?
      if self.to_user.mail_ask_me
        UserMailer.ask_user(self.id).deliver
      end
    end
  end

  def inc_counter_cache
    self.user.inc(:asks_count, 1)
  end

  def dec_counter_cache
    if self.user.asks_count > 0
      self.user.inc(:asks_count, -1)
    end
  end

  def update_log
    insert_action_log("EDIT") if self.title_changed? or self.body_changed?
  end
  
  def create_log
    insert_action_log("NEW")
  end

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("title")
      return false
    end

    if self.spam?("body")
      return false
    end

    if self.spam?("topics")
      return false
    end
  end

  def chomp_body
    if self.body == "<br>"
      return ""
    else
      chomped = self.body
      while chomped =~ /<div><br><\/div>$/i
        chomped = chomped.gsub(/<div><br><\/div>$/i, "")
      end
      return chomped
    end
  end
  
  def fill_default_values
    # 默认回复时间为当前时间，已便于排序
    if self.answered_at.blank?
      self.answered_at = Time.now
    end
  end

  # 更新话题
  # 参数 topics 可以是数组或者字符串
  # 参数 add  true 增加, false 去掉
  def update_topics(topics, add = true, current_user_id = nil)
    self.topics = [] if self.topics.blank?
    # 分割逗号
    topics = topics.split(/，|,/) if topics.class != [].class
    # 去两边空格
    topics = topics.collect { |t| t.strip if !t.blank? }.compact
    action = nil

    if add
      # 保存为独立的话题
      new_topics = Topic.save_topics(topics, current_user_id)
      self.topics += new_topics
      action = "ADD_TOPIC"
    else
      self.topics -= topics
      action = "DEL_TOPIC"
    end
    
    self.current_user_id = current_user_id
    self.topics = self.topics.uniq { |s| s.downcase }
    self.update(:topics => self.topics)
    insert_topic_action_log(action, topics, current_user_id)
  end

  # 提交问题为 spam
  def spam(voter_id,size = 1)
    self.spams_count ||= 0
    self.spam_voter_ids ||= []
    # 限制 spam ,一人一次
    return self.spams_count if self.spam_voter_ids.index(voter_id)
    self.spams_count += size
    self.spam_voter_ids << voter_id
    self.current_user_id = "NULL"
    self.save()
    return self.spams_count
  end

  def self.mmseg_text(text)
    result = Ask.search(text,:max_matches => 1)
    words = []
    result.raw_result[:words].each do |w|
      next if w[0] == "ask"
      words << ((w[0] == "rubi" and text.downcase.index("ruby")) ? "ruby" : w[0])
    end
    words
  end

  def self.search_title(text,options = {})
    limit = options[:limit] || 10
    Ask.search(text,:limit => limit)
  end

  def self.find_by_title(title)
    first(:conditions => {:title => title})
  end
  
  # 重定向问题
  def redirect_to_ask(to_id)
    # 不能重定向自己
    return -2 if to_id.to_s == self.id.to_s
    @to_ask = Ask.find(to_id)
    # 如果重定向目标的是重定向目前这个问题的，就跳过，防止无限重定向
    return -1 if @to_ask.redirect_ask_id.to_s == self.id.to_s
    self.redirect_ask_id = to_id
    self.save
    1
  end

  # 取消重定向
  def redirect_cancel
    self.redirect_ask_id = nil
    self.save
  end
  
  protected
  
    def insert_topic_action_log(action, topics, current_user_id)
      begin
        log = AskLog.new
        log.user_id = current_user_id
        log.title = topics.join(',')
        log.ask = self
        log.target_id = self.id
        log.action = action
        log.target_parent_id = self.id
        log.target_parent_title = self.title
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
    end
  
    def insert_action_log(action)
      begin
        log = AskLog.new
        log.user_id = self.current_user_id
        log.title = self.title
        log.ask = self
        log.target_id = self.id
        log.target_attr = (self.title_changed? ? "TITLE" : (self.body_changed? ? "BODY" : "")) if action == "EDIT"
        if(action == "NEW" and !self.to_user_id.blank?)
          action = "NEW_TO_USER"
          log.target_parent_id = self.to_user_id
        end
        log.action = action
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
    end

end
