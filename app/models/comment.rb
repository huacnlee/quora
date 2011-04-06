# coding: utf-8
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :body
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"

  validates_presence_of :body

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("body")
      return false
    end
  end

  before_create :fix_commentable_id
  def fix_commentable_id
    if self.commentable_id.class == "".class
      self.commentable_id = BSON::ObjectId(self.commentable_id)
    end
  end

  after_create :inc_counter_cache
  def inc_counter_cache
    self.commentable.safely.inc(:comments_count,1)
  end

  before_destroy :dec_counter_cache
  def dec_counter_cache
    self.commentable.safely.inc(:comments_count,-1)
  end

end
