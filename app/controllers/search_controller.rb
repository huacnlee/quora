# coding: utf-8
class SearchController < ApplicationController

  def index
    @asks = Ask.search_title(params["w"].to_s.strip,:limit => 20)
    set_seo_meta("关于“#{params[:w]}”的搜索结果")
    render "/asks/index"
  end

  def all
    result = Search.query(params[:q].strip,:limit => 10)
    lines = []
    result.each do |item|
      case item['type']
      when "Ask"
        lines << complete_line_ask(item)
      when "User"
        lines << complete_line_user(item)
      when "Topic"
        lines << complete_line_topic(item)
      end
    end
    render :text => lines.join("\n")
  end

  def topics
    result = Search.complete(params[:q].strip,:type => "Topic",:limit => 10)
    if params[:format] == "json"
      lines = []
      result.each do |item|
        lines << complete_line_topic(item)
      end
      render :text => lines.join("\n")
    else
      lines = []
      result.each do |item|
        lines << complete_line_topic(item)
      end
      render :text => lines.join("\n") 
    end
  end

  def asks
    result = Search.query(params[:q].strip,:type => "Ask",:limit => 10)
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << complete_line_ask(item)
      end
      render :text => lines.join("\n") 
    end
  end

  def users 
    result = Search.complete(params[:q],:type => "User",:limit => 10)
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << complete_line_user(item)
      end
      render :text => lines.join("\n") 
    end
  end

  private
    def complete_line_ask(item,hash = true)
      if hash
        "#{item['title']}#!##{item['id']}#!##{item['topics'].join(',')}#!#Ask"
      else
        "#{item.title.gsub("\n",'')}#!##{item.id}#!##{item.topics.join(',')}#!#Ask"
      end
    end

    def complete_line_topic(item,hash = true)
      if hash
        "#{item['title']}#!##{item['followers_count']}#!##{item['cover_small']}#!#Topic"
      else
        "#{item.name}#!##{item.followers_count}#!##{item.cover_small}#!#Topic"
      end
    end

    def complete_line_user(item,hash = true)
      if hash
        "#{item['title']}#!##{item['id']}#!##{item['tagline']}#!##{item['avatar_small']}#!##{item['slug']}#!#User"
      else
        "#{item.name}#!##{item.id}#!##{item.tagline}#!##{item.avatar_small}#!##{item.slug}#!#User"
      end
    end
end
