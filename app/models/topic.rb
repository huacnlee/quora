# coding: utf-8
class Topic
  include Mongoid::Document
  
  field :name
  field :summary
  field :cover
  mount_uploader :cover, CoverUploader

  field :asks_count, :type => Integer, :default => 0

  index :name
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  
  # Followers
  references_and_referenced_in_many :followers, :stored_as => :array, :inverse_of => :followed_topics, :class_name => "User"

  validates_presence_of :name
  validates_uniqueness_of :name, :case_insensitive => true

  def self.save_topics(topics, current_user_id)
    topics.each do |item|
      topic = find_by_name(item.strip)
      # find_or_create_by(:name => item.strip)
      if topic.nil?
        topic = create(:name => item.strip)
        begin
          log = TopicLog.new
          log.user_id = current_user_id
          log.title = topic.name
          log.topic = topic
          log.action = "NEW"
          log.diff = ""
          log.save
        rescue Exception => e

        end
      end
    end
  end

  def self.find_by_name(name)
    find(:first,:conditions => {:name => name})
  end
end
