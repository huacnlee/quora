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
  
end

class TopicLog < Log
  
end

class UserLog < Log
  
end

class AnswerLog < Log
  
end

class CommentLog < Log
  
end