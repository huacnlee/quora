# coding: utf-8
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :body
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  belongs_to :ask, :foreign_key => "commentable_id"
  belongs_to :answer, :foreign_key => "commentable_id"

  index :user_id
  index :commentable_type
  index :commentable_id
  index :created_at

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

  after_create :inc_counter_cache, :create_log
  def inc_counter_cache
    self.commentable.safely.inc(:comments_count,1)
  end
  
  def create_log
    log = CommentLog.new
    log.user_id = self.user_id
    log.comment = self
    log.target_id = self.id
    log.action = "NEW_#{self.commentable_type.upcase}_COMMENT"
    if self.commentable_type == "Answer"
      log.target_parent_id = (self.answer and self.answer.ask) ? self.answer.ask.id : ""
      log.target_parent_title = (self.answer and self.answer.ask) ? self.answer.ask.title : ""
      log.title = self.commentable_id
    else
      log.target_parent_title = self.ask ? self.ask.title : ""
      log.target_parent_id = self.commentable_id
      log.title = log.target_parent_title
    end
    log.diff = ""
    log.save
  end

  before_destroy :dec_counter_cache
  def dec_counter_cache
    self.commentable.safely.inc(:comments_count,-1)
  end

end
