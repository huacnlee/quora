# coding: UTF-8
class Cpanel::TopicsController < CpanelController
  
  def index
    @topics = initialize_grid(Topic, 
      :order => 'id',
      :order_direction => 'desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @topic = Topic.find(params[:id])
  end
  
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to(cpanel_topics_path, :notice => 'Topic 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to(cpanel_topics_path, :notice => 'Topic 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_topics_path,:notice => "删除成功。") }
      format.json
    end
  end
end
