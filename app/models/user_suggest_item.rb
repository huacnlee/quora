require "bson"
class UserSuggestItem
  attr_accessor :user_id, :type, :id
  def initialize(options = {})
    options.keys.each do |k|
      eval("self.#{k} = options[k]")
    end
  end

  def self.gkey(user_id)
    "quora.user_suggest_item:#{user_id}"
  end

  def key
    UserSuggestItem.gkey(self.user_id)
  end

  def save
    # 从数组右边新增
    $redis.rpush(self.key,self.to_json)
    true
  end

  def self.write(user_id, type, id)
    usi = new(:user_id => user_id, :type => type, :id => id)
    usi.save
  end

  # 用于更新的时候先删除
  def self.delete_all(user_id)
    $redis.del(UserSuggestItem.gkey(user_id))
  end

  # 去得单个
  def self.get(user_id, type, id)
    # TODO: 这里有性能问题，查询的时候是把用户所有的项从Redis里面去出来的，多余的浪费内存传输
    items = UserSuggestItem.gets(user_id, :redis_limit => $redis.llen(UserSuggestItem.gkey(user_id)), :format => "string")
    items.each do |item|
      json = JSON.parse(item)
      if json['type'] == type and json['id'] == id.to_s
        return json
      end
    end
    nil
  end

  def self.count(user_id)
    $redis.llen(UserSuggestItem.gkey(user_id))
  end


  def self.delete(user_id, type, id)
    # TODO: 这里有性能问题，查询的时候是把用户所有的项从Redis里面去出来的，多余的浪费内存传输
    items = UserSuggestItem.gets(user_id, :redis_limit => UserSuggestItem.count(user_id), :format => "string")
    items.each do |item|
      json = JSON.parse(item)
      # 如果 type 和 id 一致
      if json['type'] == type and json['id'] == id.to_s
        # 删除
        $redis.lrem(UserSuggestItem.gkey(user_id),0, item) 
        return true
      end
    end
    false
  end

  def self.gets(user_id, options = {})
    redis_limit = options[:redis_limit] || nil
    limit = options[:limit] || 10
    format = options[:format] || "json"

    if redis_limit == nil
      max = UserSuggestItem.count(user_id)
      idx = rand(max)
      if (idx + limit) >= max
        idx = max - limit
      end
    else
      max = redis_limit
      idx = 0
    end

    items = $redis.lrange(UserSuggestItem.gkey(user_id), idx, max)
    return [] if items.blank?

    # 返回原始字符串格式
    return items if format != "json"

    # 返回 JSON 格式
    result = []
    user_ids, topic_ids = [],[]
    items.random_pick(limit).each do |item|
      json = JSON.parse(item)
      if json['type'] == "User"
        user_ids << json['id']
      else
        topic_ids << json['id']
      end
    end
    result += User.find(user_ids)
    result += Topic.find(topic_ids)
    result
  end

  # 取得不感兴趣的列表
  def self.get_mutes(user_id)
    key = "#{UserSuggestItem.gkey(user_id)}:mutes"
    $redis.llen(key)
    max = $redis.llen(key)
    items = $redis.lrange(key, 0, max)
    result = []
    items.each do |item|
      json = JSON.parse(item)
      result << json
    end
    result
  end

  # 不感兴趣
  def self.mute(user_id, type, id)
    # TODO: 需要防止重复插入
    key = "#{UserSuggestItem.gkey(user_id)}:mutes"
    val = { :type => type, :id => id }
    $redis.rpush(key,val.to_json)
    UserSuggestItem.delete(user_id, type, id)
    true
  end

end
