# coding: utf-8
class Topic
  include Mongoid::Document
  
  field :name
  field :summary
  field :cover
  mount_uploader :cover, CoverUploader

  field :asks_count, :type => Integer, :default => 0

  index :name

  validates_presence_of :name
  validates_uniqueness_of :name, :case_insensitive => true

  def self.save_topics(topics)
    topics.each do |item|
      find_or_create_by(:name => item.strip)
    end
  end

  def self.find_by_name(name)
    find(:first,:conditions => {:name => name})
  end
end
