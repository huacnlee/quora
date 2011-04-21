# coding: utf-8
module UsersHelper
  def user_name_tag(user, options = {})
    options[:url] ||= false
    return "" if user.blank?
    return "匿名用户" if !user.deleted.blank?
    return user.name if user.slug.blank?
    url = options[:url] == true ? user_url(user.slug) : user_path(user.slug)
    raw "<a#{options[:is_notify] == true ? " onclick=\"mark_notifies_as_read(this, '#{options[:notify].id}');\"" : ""} href=\"#{url}\" class=\"user\" title=\"#{user.name}\">#{user.name}</a>"
  end
  
  def user_avatar_tag(user,size)
    return "" if user.blank?
    return "" if user.slug.blank?
    if user.deleted.blank?
      url = eval("user.avatar.#{size}.url")
      if url.blank?
        url = ""
      end
      raw "<a href=\"#{user_path(user.slug)}\" class=\"user\" title=\"#{user.name}\">#{image_tag(url, :class => size)}</a>"
    else
      raw image_tag("avatar/#{size.to_s}.jpg", :title => "匿名用户")
    end
  end

  def user_tagline_tag(user,options = {})
    prefix = options[:prefix] || ""
    return "" if user.tagline.blank?
    raw "#{prefix}#{truncate(user.tagline, :length => 30)}"
  end

  def user_sex_title(user)
    if current_user
      return "我" if user.id == current_user.id
    end
    user.girl.blank? == true ? "他" : "她"
  end
end
