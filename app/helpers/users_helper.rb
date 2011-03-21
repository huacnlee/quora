# coding: utf-8
module UsersHelper
  def user_name_tag(user)
    return "" if user.blank?
    raw "<a href=\"#{user_path(user.slug)}\" class=\"user\" title=\"#{user.name}\">#{user.name}</a>"
  end
  
  def user_avatar_tag(user,size)
    return "" if user.blank?
    url = eval("user.avatar.small.url")
    if url.blank?
      url = ""
    end
    raw "<a href=\"#{user_path(user.slug)}\" class=\"user\" title=\"#{user.name}\">#{image_tag(url, :class => size)}</a>"
  end
end
