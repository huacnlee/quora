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

  # 提问人
  belongs_to :user, :inverse_of => :asks

  # 评论，内嵌
  embeds_many :comments

  # 所属话题
  has_many :topics, :store_as => :array

  # 回答
  has_many :answers
  # 最后个回答
  belongs_to :last_answer, :class_name => 'Answer'
  # 最后回答者
  belongs_to :last_answer_user, :class_name => 'User'

  attr_protected :user_id
  validates_presence_of :user_id, :title

  scope :last_actived, desc(:answered_at)

  before_save :fill_default_values
  def fill_default_values
    # 默认回复时间为当前时间，已便于排序
    if self.answered_at.blank?
      self.answered_at = Time.now
    end
  end


end
