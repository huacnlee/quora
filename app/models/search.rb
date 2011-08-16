# coding: utf-8
class Search
  attr_accessor :type, :title, :id, :exts
  def initialize(options = {})
    self.exts = []
    options.keys.each do |k|
      eval("self.#{k} = options[k]")
    end
  end
  
  # 生成 uuid，用于作为 hashes 的 field, sets 关键词的值
  def self.mk_sets_key(type, key)
    "#{type}:#{key.downcase}"
  end
  
  def self.mk_complete_key(type)
    "Compl#{type}"
  end
  
  def self.word?(word)
    return !/^[\w\u4e00-\u9fa5]+$/i.match(word.force_encoding("UTF-8")).blank?
  end

  def save
    return if self.title.blank?
    data = {:title => self.title, :id => self.id, :type => self.type}
    self.exts.each do |f|
      data[f[0]] = f[1]
    end
    
    # 将原始数据存入 hashes
    res = $redis_search.hset(self.type, self.id, data.to_json)
    # 保存 sets 索引，以分词的单词为key，用于后面搜索，里面存储 ids
    words = MMSeg.split(self.title)
    return if words.blank?
    words.each do |word|
      next if not Search.word?(word)
      save_zindex(word)
      key = Search.mk_sets_key(self.type,word)
      $redis_search.sadd(key, self.id)
    end
  end
  
  def save_zindex(word)
    return if not Search.word?(word)
    word = word.downcase
    key = Search.mk_complete_key(self.type)
    (1..(word.length)).each do |l|
      prefix = word[0...l]
      $redis_search.zadd(key, 0, prefix)
    end
    $redis_search.zadd(key, 0, word + "*")
  end

  def self.remove(options = {})
    # $redis_search.del(generate_key(options[:title],options[:type]))
  end

  def self.complete(w, options = {})
    limit = options[:limit] || 10 
    type = options[:type] || "Topic"

    prefix_matchs = []
    rangelen = 100 # This is not random, try to get replies < MTU size
    prefix = w.downcase
    key = Search.mk_complete_key(type)
    start = $redis_search.zrank(key,prefix)

    return [] if !start
    count = limit
    while prefix_matchs.length <= count
      range = $redis_search.zrange(key,start,start+rangelen-1)
      start += rangelen
      break if !range or range.length == 0
      range.each {|entry|
        minlen = [entry.length,prefix.length].min
        if entry[0...minlen] != prefix[0...minlen]
          count = prefix_matchs.count
          break
        end
        if entry[-1..-1] == "*" and prefix_matchs.length != count
          prefix_matchs << entry[0...-1]
        end
      }
    end
    words = []
    words = prefix_matchs.uniq.collect { |w| Search.mk_sets_key(type,w) }
    ids = $redis_search.sunion(*words)
    return [] if ids.blank?
    hmget(type,ids, limit)
  end

  def self.query(text,options = {})
    result = []
    return result if text.strip.blank?

    words = MMSeg.split(text)
    limit = options[:limit] || 10
    type = options[:type] || "topic"
    words = words.collect { |w| Search.mk_sets_key(type,w) }
    return result if words.blank?
    ids = $redis_search.sinter(*words)
    hmget(type,ids, limit)
  end
  
  private
    def self.hmget(type, ids, limit = 10)
      result = []
      return result if ids.blank?
      $redis_search.hmget(type,*ids).each do |r|
        begin
          result << JSON.parse(r)
        rescue => e
          Rails.logger.info { "Search.query failed: #{e}" }
        end
      end
      items = sort_result(result, type)
      items = items[0..limit-1] if items.length > limit
      items
    end
  
    def self.sort_result(items, type)
      return items if items.blank?
      case type
      when "topic"
        items = items.sort { |x,y| y['followers_count'] <=> x['followers_count'] }
      when "user"
        items = items.sort { |x,y| y['score'] <=> x['score'] }
      end
      items
    end
end
