class TopicsController < ApplicationController
  def index
  end

  def show
    name = params[:id].strip
    @topic = Topic.find_by_name(name)
    @asks = Ask.all_in(:topics => name)
  end
end
