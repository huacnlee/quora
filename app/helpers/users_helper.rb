# coding: utf-8
module UsersHelper
  def user_name_tag(user)
    raw "<a href=\"#{user_path(user.slug)}\" title=\"#{user.name}\">#{user.name}</a>"
  end
end
