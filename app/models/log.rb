# coding: utf-8
class Log
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
  field :target_attr
  field :action
  field :diff
  field :target_id, :type => Integer
  
  index :target_attr
  index :action
  
  belongs_to :user, :inverse_of => :logs
  attr_protected :user_id
end

class AskLog < Log
  belongs_to :ask, :inverse_of => :logs, :foreign_key => :target_id
end

class TopicLog < Log
  
end

class UserLog < Log
  
end

class AnswerLog < Log
  belongs_to :answer, :inverse_of => :logs, :foreign_key => :target_id
end

class CommentLog < Log
  
end