module ApplicationHelper
  def admin?(user)
    return true if Setting.admin_emails.index(user.email)
    return false
  end
  
end
