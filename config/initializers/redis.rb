require "redis"

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
$redis = Redis.new(:host => redis_config[:host],:port => redis_config[:port])

# Resque
Resque.redis = $redis
Resque.redis.namespace = "resque:quora"
