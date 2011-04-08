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
    "quora:searchs:"
  end

  def self.generate_key(title)
    "#{Search.key_prefix}#{title.downcase}"
  end

  def save
    data = {:title => self.title, :id => self.id, :type => self.type}
    self.exts.each do |f|
      data[f[0]] = f[1]
    end
    
    res = $redis.set Search.generate_key(self.title), data.to_json
    if res == "OK"
      return true
    end
    false
  end

  def self.remove(options = {})
    $redis.del(generate_key(options[:title]))
  end

  def self.query(text,options = {})
    return [] if text.strip.blank?

    words = Ask.mmseg_text(text)
    limit = options[:limit] || 10
    type = options[:type] || nil
    word_match = words.collect(&:downcase).join("*")
    word_match = "#{Search.key_prefix}*#{word_match}*"
    puts "keys:#{word_match}"
    keys = $redis.keys(word_match)[0,limit]
    result = []
    keys.each do |k|
      # TODO: 这里需要改为 mult get
      r = $redis.get(k)
      begin
        item = JSON.parse(r)
        # item['title'] = Search.highlight(item['title'],words)
        result << item
      rescue => e
        Rails.logger.info { "Search.query failed: #{e}" }
      end
    end
    result.sort { |b,a| a['type'] <=> b['type'] }
  end
end
