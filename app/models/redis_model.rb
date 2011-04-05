# coding: utf-8
class RedisModel
  def initialize(options = {})
    options.keys.each do |k|
      eval("self.#{k} = options[k].to_s")
    end
  end
end
