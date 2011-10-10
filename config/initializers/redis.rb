require "redis"
require "redis-search"

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
$redis = Redis.new(:host => redis_config['host'],:port => redis_config['port'])
$redis.select("0")

redis_search = Redis.new(:host => redis_config['host'],:port => redis_config['port'])
redis_search.select("3")
Redis::Search.configure do |config|
  config.redis = redis_search
  config.complete_max_length = 30
end

# Resque
Resque.redis = Redis.new(:host => redis_config['host'],:port => redis_config['port'])
Resque.redis.namespace = "resque:quora"
