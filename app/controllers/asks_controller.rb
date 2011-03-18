# coding: UTF-8
class AsksController < ApplicationController
  
  def index
    @ask = Ask.last_actived.paginate(:page => params[:page], :per_page => 20)

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
    @ask.user_id = @current_user.id

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(asks_path, :notice => '问题创建成功。') }
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
        format.html { redirect_to(asks_path, :notice => '问题更新成功。') }
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
      format.html { redirect_to(asks_path,:notice => "问题删除成功。") }
      format.json
    end
  end
end
