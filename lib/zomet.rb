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
      uri = URI.parse("http://#{@zomet_config["server"]}")
      @zomet_config["host"] ||= uri.host
      @zomet_config["port"] ||= uri.port
    end
    
    def pub_to_browser(options)
      return if !options.is_a?(Hash)
      begin
        Rails.logger.info "ZOMET: #{options.inspect}"
        Juggernaut.publish(options[:channel], options[:data])
      rescue Exception => e
        Rails.logger.error "ZOMET ERROR: #{e.message}"
      end
    end
  end
end

ActionController::Base.send(:include, Zomet)
