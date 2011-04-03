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

end

class AnswerLog < Log
  belongs_to :answer, :inverse_of => :logs, :foreign_key => :target_id
end

class CommentLog < Log
  belongs_to :comment, :inverse_of => :logs, :foreign_key => :target_id
end
