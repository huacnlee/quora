# 提供统一的Comet Server接口封装
# nowazhu@gmail.com 
# 2011-04-14

module Zomet
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def use_zomet(options = nil)
      include Zomet::InstanceMethods
      
      before_filter :load_zomet_config
    end
  end
  
  module InstanceMethods
    def load_zomet_config
      @zomet_config = YAML.load_file("#{Rails.root}/config/zomet.yml")[Rails.env]
    end
    
    def pub_to_browser(options)
      return if !options.is_a?(Hash)
      begin
        # TODO: 暂时使用新开线程的方式发送，后期可以先队列到Redis，然后开启一个Worker来发送
        Rails.logger.info "ZOMET: curl http://#{@zomet_config["server"]}/faye -d 'message={\"channel\":\"#{options[:channel]}\", \"data\":{\"#{options[:data_type]}\":#{options[:data]}}}'"
        Thread.new do
          Rails.logger.info "ZOMETTED: " + `curl http://#{@zomet_config["server"]}/faye -d 'message={"channel":"#{options[:channel]}", "data":{"#{options[:data_type]}":#{options[:data]}}}'`
        end
      rescue Exception => e
        Rails.logger.error "ZOMET ERROR: #{e.message}"
      end
    end
  end
end

ActionController::Base.send(:include, Zomet)
