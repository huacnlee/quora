class TopicsController < ApplicationController
  def index
  end

  def show
    name = params[:id].strip
    @per_page = 10
    @topic = Topic.find_by_name(name)
    if @topic.blank?
      return render_404
    end
    @asks = Ask.all_in(:topics => [name]).desc(:id).paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta(@topic.name,:description => @topic.summary)

    if params[:format] == "js"
      render "/asks/index.js"
    end
  end
  
  def follow
    @topic = Topic.find_by_name(params[:id])
    if not @topic
      render :text => "0"
      return
    end
    current_user.follow_topic(@topic)
    render :text => "1"
  end
  
  def unfollow
    @topic = Topic.find_by_name(params[:id])
    if not @topic
      render :text => "0"
      return
    end
    current_user.unfollow_topic(@topic)
    render :text => "1"
  end
end
