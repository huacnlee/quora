# coding: utf-8
class Ask
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
  field :body
  # 最后回答时间
  field :answered_at, :type => DateTime
  field :answers_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0
  field :topics, :type => Array, :default => []
  field :spams_count, :type => Integer, :default => 0
  field :spam_voter_ids, :type => Array, :default => []

  index :topics

  # 提问人
  belongs_to :user, :inverse_of => :asks

  # 评论，内嵌
  embeds_many :comments

  # 回答
  has_many :answers
  # 最后个回答
  belongs_to :last_answer, :class_name => 'Answer'
  # 最后回答者
  belongs_to :last_answer_user, :class_name => 'User'

  attr_protected :user_id
  validates_presence_of :user_id, :title

  # 正常可显示的问题, 前台调用都带上这个过滤
  scope :normal, where(:spams_count.lt => Setting.ask_spam_max)
  scope :last_actived, desc(:answered_at)
  scope :recent, desc("$natural")
  # 除开一些 id，如用到 mute 的问题，传入用户的 muted_ask_ids
  scope :exclude_ids, lambda { |id_array| not_in("_id" => (id_array ||= [])) } 
  scope :only_ids, lambda { |id_array| any_in("_id" => (id_array ||= [])) } 

  before_save :fill_default_values
  def fill_default_values
    # 默认回复时间为当前时间，已便于排序
    if self.answered_at.blank?
      self.answered_at = Time.now
    end
  end

  # 更新话题
  # 参数 topics 可以是数组或者字符串
  # 参数 add  true 增加, false 去掉
  def update_topics(topics, add = true)
    self.topics = [] if self.topics.blank?
    topics = [topics] if topics.class != [].class
    # 去两边空格
    topics = topics.collect { |t| t.strip if !t.blank? }.compact

    if add
      self.topics += topics
      # 保存为独立的话题
      Topic.save_topics(topics)
    else
      self.topics -= topics
    end
    
    self.topics = self.topics.uniq
    self.update(:topics => self.topics)
  end

  # 提交问题为 spam
  def spam(voter_id)
    self.spams_count ||= 0
    self.spam_voter_ids ||= []
    # 限制 spam ,一人一次
    return self.spams_count if self.spam_voter_ids.index(voter_id)
    self.spams_count += 1
    self.spam_voter_ids << voter_id
    self.save()
    return self.spams_count
  end


end
