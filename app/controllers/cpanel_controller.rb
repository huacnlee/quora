class CpanelController < ApplicationController
  layout "cpanel"
  before_filter :require_admin

  def require_admin
    if current_user.blank?
      render_404
      return
    end
    if not Setting.admin_emails.index(current_user.email)
      render_404
    end
  end

end
