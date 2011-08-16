require "redis"

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
$redis = Redis.new(:host => redis_config[:host],:port => redis_config[:port])
$redis.select("quora")

$redis_search = Redis.new(:host => redis_config[:host],:port => redis_config[:port])
$redis_search.select("quora.search")

# Resque
Resque.redis = Redis.new(:host => redis_config[:host],:port => redis_config[:port])
Resque.redis.namespace = "resque:quora"
