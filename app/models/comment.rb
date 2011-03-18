# coding: utf-8
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :body
  
  belongs_to :user

  embedded_in :answer, :inverse_of => :comments
  embedded_in :ask, :inverse_of => :comments
end
