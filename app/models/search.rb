# coding: utf-8
class Search
  attr_accessor :type, :title, :id, :exts
  def initialize(options = {})
    self.exts = []
    options.keys.each do |k|
      eval("self.#{k} = options[k]")
    end
  end

  def self.key_prefix
    "quora.searchs"
  end

  def self.generate_key(title,type)
    "#{Search.key_prefix}#!##{title.downcase}#!##{type}"
  end

  def save
    data = {:title => self.title, :id => self.id, :type => self.type}
    self.exts.each do |f|
      data[f[0]] = f[1]
    end
    
    res = $redis.set Search.generate_key(self.title,self.type), data.to_json
    if res == "OK"
      return true
    end
    false
  end

  def self.remove(options = {})
    $redis.del(generate_key(options[:title],options[:type]))
  end

  def self.query(text,options = {})
    return [] if text.strip.blank?

    words = Ask.mmseg_text(text)
    limit = options[:limit] || 10
    type = options[:type] || nil
    word_match = words.collect(&:downcase).join("*")
    if type.blank?
      # 分三次查询，依次按 Topic, User, Ask 排列
      reg = "#{Search.key_prefix}#!#*#{word_match}*#!#Topic"
      keys = $redis.keys(reg)[0,limit]
      if keys.length < limit
        reg = "#{Search.key_prefix}#!#*#{word_match}*#!#User"
        keys += $redis.keys(reg)[0,limit]
        if keys.length < limit
          reg = "#{Search.key_prefix}#!#*#{word_match}*#!#Ask"
          keys += $redis.keys(reg)[0,limit]
        end
      end
    else
      reg = "#{Search.key_prefix}#!#*#{word_match}*#!##{type}"
      keys = $redis.keys(reg)[0,limit]
    end
    keys = keys.uniq[0,limit]
    result = []
    $redis.mget(*keys).each do |r|
      begin
        result << JSON.parse(r)
        result << item
      rescue => e
        Rails.logger.info { "Search.query failed: #{e}" }
      end
    end
    result
  end
end
