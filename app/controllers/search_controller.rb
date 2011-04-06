# coding: utf-8
class SearchController < ApplicationController

  def index
    if params[:format] == "json"
      result = Search.query(params["w"],:limit => 10)
      render :json => result.to_json
    else
      @asks = Ask.search_title(params["w"],:limit => 20)
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
