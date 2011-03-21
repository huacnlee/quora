# coding: utf-8
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :body
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  after_create :inc_counter_cache
  def inc_counter_cache
    self.commentable.safely.inc(:comments_count,1)
  end

  before_destroy :dec_counter_cache
  def dec_counter_cache
    self.commentable.safely.inc(:comments_count,-1)
  end

end
