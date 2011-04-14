# coding: UTF-8
class Cpanel::ReportSpamsController < CpanelController
  
  def index
    @report_spams = initialize_grid(ReportSpam, 
      :order => 'id',
      :order_direction => 'desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @report_spam = ReportSpam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def destroy
    @report_spam = ReportSpam.find(params[:id])
    @report_spam.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_report_spams_path,:notice => "删除成功。") }
      format.json
    end
  end
end
