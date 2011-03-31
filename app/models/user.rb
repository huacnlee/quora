# coding: utf-8
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Voter
  
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  field :name
  field :slug
  field :tagline
  field :bio
  field :avatar
  field :website

  # 不敢兴趣的问题
  field :muted_ask_ids, :type => Array, :default => []
  # 关注的问题
  field :followed_ask_ids, :type => Array, :default => []

  # 邀请字段
  field :invitation_token
  field :invitation_sent_at, :type => DateTime

  field :asks_count, :type => Integer, :default => 0
  has_many :asks

  field :answers_count, :type => Integer, :default => 0
  has_many :answers

  embeds_many :authorizations

  attr_accessor  :password_confirmation
  attr_accessible :email, :password,:name, :slug, :tagline, :bio, :avatar, :website

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end
  
  mount_uploader :avatar, AvatarUploader

  def self.create_from_hash(auth)  
		user = User.new
		user.name = auth["user_info"]["name"]  
		user.email = auth['user_info']['email']
		user.save(false)
		user.reset_persistence_token! #set persistence_token else sessions will not be created
		user
  end  

  before_validation :auto_slug
  def auto_slug
    if self.slug.blank?
      self.slug = self.email.split("@")[0]
      self.slug = self.slug.safe_slug
    end
    # 如果已有他人用这个 slug，就用 id
    if self.slug.blank? or User.find_by_slug(self.slug)
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
  def mute_ask(ask_id)
    self.muted_ask_ids ||= []
    return if self.muted_ask_ids.index(ask_id)
    self.muted_ask_ids << ask_id
    self.save
  end

end
