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

  after_create :save_to_ask_and_update_answered_at
  def save_to_ask_and_update_answered_at
    self.ask.update_attributes({:answered_at => self.created_at, 
                               :last_answer_id => self.id,
                               :last_answer_user_id => self.user_id })
    self.ask.inc(:answers_count,1)
  end
end
