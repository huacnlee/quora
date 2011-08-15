# coding: utf-8
class AskSuggestTopic
  include Mongoid::Document

  belongs_to :ask
  field :topics, :type => Array, :default => []

  def self.find_by_ask(ask)
    return [] if !ask.topics.blank?
    item = self.find_or_initialize_by(:ask_id => ask.id)
    return item.topics if !item.topics.blank?

    # 生成内容
    words = MMSeg.split(ask.title)
    topics = Topic.any_in(:name => words.collect { |w| /^#{w}$/i } )
    topics.sort { |a,b| b.followers_count <=> a.followers_count }
    topics_array = topics.collect { |t| t.name }
    if topics_array.length > 8
      topics_array = topics_array[0,8]
    end

    item.topics = topics_array
    item.save
    return item.topics
  end
end
