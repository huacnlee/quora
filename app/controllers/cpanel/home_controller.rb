class Cpanel::HomeController < CpanelController
  def index
    redirect_to cpanel_asks_path
  end
end
