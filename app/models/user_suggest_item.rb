class UserSuggestItem
  attr_accessor :user_id, :type, :id, :suid, :name, :summary, :slug, :image
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

  # 用于更新的时候先删除
  def self.delete_all(user_id)
    $redis.del(UserSuggestItem.gkey(user_id))
  end

  # 去得单个
  def self.get(user_id, type, id)
    # TODO: 这里有性能问题，查询的时候是把用户所有的项从Redis里面去出来的，多余的浪费内存传输
    items = UserSuggestItem.gets(user_id, :limit => $redis.llen(UserSuggestItem.gkey(user_id)), :format => "string")
    items.each do |item|
      json = JSON.parse(item)
      if json['type'] == type and json['id'] == id
        return json
      end
    end
    nil
  end

  def self.delete(user_id, type, id)
    # 获得30个旧的items（因为列表默认是10个，所以就算其他地方有删除，也应该在30以内，新增的都在数组右边)
    items = UserSuggestItem.gets(user_id, :limit => 30, :format => "string")
    items.each do |item|
      json = JSON.parse(item)
      # 如果 type 和 id 一致
      if json['type'] == type and json['id'] == id
        # 删除
        $redis.lrem(UserSuggestItem.gkey(user_id),0, item) 
        return true
      end
    end
    false
  end

  # TODO: 用户改 slug 和 话题改名后需要处理删除
  def self.gets(user_id, options = {})
    limit = options[:limit] || 10
    format = options[:format] || "json"

    items = $redis.lrange(UserSuggestItem.gkey(user_id), 0, limit)
    return [] if items.blank?

    # 返回原始字符串格式
    return items if format != "json"

    # 返回 JSON 格式
    items.collect { |item| JSON.parse(item) }
  end

end
