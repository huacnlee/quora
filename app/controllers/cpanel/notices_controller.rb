# coding: UTF-8
class Cpanel::NoticesController < CpanelController
  
  def index
    @notices = initialize_grid(Notice, 
      :order => 'id',
      :order_direction => 'desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @notice = Notice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @notice = Notice.new
    @notice.end_at = Time.now + 1.days

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @notice = Notice.find(params[:id])
  end
  
  def create
    @notice = Notice.new(params[:notice])

    respond_to do |format|
      if @notice.save
        format.html { redirect_to(cpanel_notices_path, :notice => 'Notice 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @notice = Notice.find(params[:id])

    respond_to do |format|
      if @notice.update_attributes(params[:notice])
        format.html { redirect_to(cpanel_notices_path, :notice => 'Notice 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_notices_path,:notice => "删除成功。") }
      format.json
    end
  end
end
