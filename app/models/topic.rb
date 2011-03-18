# coding: utf-8
class Topic
  include Mongoid::Document
  
  field :name
  field :summary
  field :cover

  field :asks_count, :type => Integer, :default => 0
  has_many :asks
  
end
