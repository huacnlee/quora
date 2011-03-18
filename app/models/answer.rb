# coding: utf-8
class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body
  belongs_to :ask, :inverse_of => :answers, :counter_cache => true
  belongs_to :user, :inverse_of => :answers, :counter_cache => true
  
  embeds_many :comments
end
