class TopicsController < ApplicationController
  def index
  end

  def show
    name = params[:id].strip
    @per_page = 10
    @topic = Topic.find_by_name(name)
    @asks = Ask.all_in(:topics => [name]).desc(:id).paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/index.js"
    end
  end
end
