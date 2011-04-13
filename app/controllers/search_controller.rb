# coding: utf-8
class SearchController < ApplicationController

  def index
    @per_page = 10
    if params[:format] == "json"
      result = Search.query(params["w"].to_s.strip,:limit => 10)
      render :json => result.to_json
    else
      @asks = Ask.search(params["w"].to_s.strip,:page => params[:page], :per_page => @per_page)
      set_seo_meta("关于“#{params[:w]}”的搜索结果")
      render "/asks/index"
    end
  end

  def topics
    result = Search.query(params[:q],:type => "Topic",:limit => 10)
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << item['title']
      end
      render :text => lines.join("\n") 
    end
  end

  def asks
    result = Search.query(params[:q],:type => "Ask",:limit => 10)
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << "#{item['title']}#!##{item['id']}"
      end
      render :text => lines.join("\n") 
    end
  end

  def users 
    result = Search.query(params[:q],:type => "User",:limit => 10)
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << "#{item['title']}#!##{item['id']}#!##{item['tagline']}#!##{item['avatar_small']}#!##{item['slug']}"
      end
      render :text => lines.join("\n") 
    end
  end
end
