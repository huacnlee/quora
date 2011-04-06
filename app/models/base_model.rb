# coding: utf-8
class BaseModel
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
