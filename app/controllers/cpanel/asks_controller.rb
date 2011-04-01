# coding: UTF-8
class Cpanel::AsksController < CpanelController
  
  def index
    @asks = initialize_grid(Ask, 
      :order => 'id',
      :order_direction => 'desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @ask = Ask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @ask = Ask.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @ask = Ask.find(params[:id])
  end
  
  def create
    @ask = Ask.new(params[:ask])

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(cpanel_asks_path, :notice => 'Ask 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @ask = Ask.find(params[:id])

    respond_to do |format|
      if @ask.update_attributes(params[:ask])
        format.html { redirect_to(cpanel_asks_path, :notice => 'Ask 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @ask = Ask.find(params[:id])
    @ask.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_asks_path,:notice => "删除成功。") }
      format.json
    end
  end
end
