# coding: utf-8
module BaseModel
  extend ActiveSupport::Concern
  module InstanceMethods
    # 检测敏感词
    def spam?(attr)
      value = eval("self.#{attr}")
      return false if value.blank?
      if value.class == [].class
        value = value.join(" ")
      end
      spam_reg = Regexp.new(Setting.spam_words)
      if matched = spam_reg.match(value)
        self.errors.add(attr,"带有敏感内容[#{matched.to_a.join(",")}],请注意一下！")
        return false
      end
    end

  end

  module ClassMethods
    # Redis 搜索存储索引
    def redis_search_index(options = {})
      title_field = options[:title_field] || :title
      ext_fields = options[:ext_fields] || []
      class_eval %(
        def redis_search_ext_fields(ext_fields)
          exts = {}
          ext_fields.each do |f|
            exts[f] = instance_eval(f.to_s)
          end
          exts
        end

        after_create :create_search_index
        def create_search_index
          s = Search.new(:title => self.#{title_field}, :id => self.id, 
                          :exts => self.redis_search_ext_fields(#{ext_fields}), 
                          :type => self.class.to_s)
          s.save
        end

        before_destroy :remove_search_index
        def remove_search_index
          Search.remove(:title => self.#{title_field}, :type => self.class.to_s)
        end

        before_update :update_search_index
        def update_search_index
          Rails.logger.debug { self.#{title_field}_was }
          Search.remove(:title => self.#{title_field}_was, :type => self.class.to_s)
          self.create_search_index
        end
      )
    end
  end
end
