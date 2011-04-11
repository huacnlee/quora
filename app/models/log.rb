# coding: utf-8
class Log
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
  field :target_attr
  field :action
  field :diff
  field :target_id
  field :target_parent_id
  field :target_parent_title
  
  index :target_attr
  index :action
  
  belongs_to :user, :inverse_of => :logs
  
  attr_protected :user_id
end

class AskLog < Log
  belongs_to :ask, :inverse_of => :logs, :foreign_key => :target_id
end

class TopicLog < Log
  belongs_to :topic, :inverse_of => :logs, :foreign_key => :target_id
end

class UserLog < Log
  # belongs_to :user, :inverse_of => :logs, :foreign_key => :target_id
  
  validates_uniqueness_of :target_id, 
                          :scope => [:user_id, :target_id, :target_parent_id], 
                          :if => proc { |obj| obj.action == "AGREE" }

  after_save :send_notification
  
  def send_notification
    case self.action
    when "FOLLOW_USER"
      Notification.create(user_id: self.target_id, 
                          log_id: self.id, 
                          target_id: self.target_id, 
                          action: "FOLLOW")
    when "AGREE"
      answer = Answer.find(self.target_id)
      Notification.create(user_id: answer.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: "AGREE_ANSWER") if answer
    when "THANK_ANSWER"
      answer = Answer.find(self.target_id)
      Notification.create(user_id: answer.user_id, 
                          log_id: self.id, 
                          target_id: self.target_id,
                          action: self.action)
    end
  end
end

class AnswerLog < Log
  belongs_to :answer, :inverse_of => :logs, :foreign_key => :target_id
  
  after_save :send_notification
  
  def send_notification
    case self.action
    when "NEW"
      Notification.create(user_id: self.answer.ask.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: "NEW_ANSWER") if self.answer and self.answer.ask and self.answer.user_id != self.answer.ask.user_id
    end
  end
end

class CommentLog < Log
  belongs_to :comment, :inverse_of => :logs, :foreign_key => :target_id
  
  after_save :send_notification
  
  def send_notification
    case self.action
    when "NEW_ASK_COMMENT"
      Notification.create(user_id: self.comment.ask.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: self.action) if self.comment and self.comment.ask and self.comment.ask.user_id != self.comment.user_id
    when "NEW_ANSWER_COMMENT"
      Notification.create(user_id: self.comment.answer.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: self.action) if self.comment and self.comment.answer and self.comment.answer.ask and self.comment.answer.user_id != self.comment.user_id
    end
  end
end
