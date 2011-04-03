# coding: utf-8
class SearchController < ApplicationController

  def index
    if params[:format] == "json"
      result = Ask.search_title(params["w"],:limit => 10)
      puts result[:words]
      simple_items = result[:items].collect do |item|
        {:topics => item.topics,
          :title => item.title,
          :_id => item.id}
      end
      render :json => simple_items.to_json
    else
      @asks = Ask.search_title(params["w"],:limit => 20)[:items]
      set_seo_meta("关于“#{params[:w]}”的搜索结果")
      render "/asks/index"
    end
  end

  def topics
    if params[:format] == "json"
      @topics = Topic.search_name(params[:w],:limit => 10)
      render :json => @topics.to_json(:only => [:id,:name])
    end

  end
end
