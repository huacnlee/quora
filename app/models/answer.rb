# coding: utf-8
class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body
  field :votes_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0

  belongs_to :ask, :inverse_of => :answers, :counter_cache => true
  belongs_to :user, :inverse_of => :answers, :counter_cache => true

  
  validates_presence_of :user_id, :body
  
  embeds_many :comments

  def vote(inc = true,user)
    if inc == true
      self.safely.inc(:votes_count, 1)
    else
      self.safely.inc(:votes_count, -1)
    end
  end
end
