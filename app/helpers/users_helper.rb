# coding: utf-8
module UsersHelper
  def user_name_tag(user)
    return "" if user.blank?
    raw "<a href=\"#{user_path(user.slug)}\" class=\"user\" title=\"#{user.name}\">#{user.name}</a>"
  end
  
  def user_avatar_tag(user,size)
    return "" if user.blank?
    url = eval("user.avatar.#{size}.url")
    if url.blank?
      url = ""
    end
    raw "<a href=\"#{user_path(user.slug)}\" class=\"user\" title=\"#{user.name}\">#{image_tag(url, :class => size)}</a>"
  end

  def user_tagline_tag(user,options = {})
    prefix = options[:prefix] || ""
    return "" if user.tagline.blank?
    raw "#{prefix}#{truncate(user.tagline, :length => 30)}"
  end
end
