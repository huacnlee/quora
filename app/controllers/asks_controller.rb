# coding: UTF-8
class AsksController < ApplicationController
  before_filter :require_user, :except => [:index,:answer,:update_topic,:show]
  before_filter :require_user_js, :only => [:answer]
  before_filter :require_user_text, :only => [:update_topic,:spam, :mute, :unmute, :follow, :unfollow]
  
  def index
    @per_page = 10
    @asks = Ask.normal.recent.includes(:user,:last_answer,:last_answer_user,:topics).paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("最新提出的问题")
  end

  def search
    if params[:format] == "json"
      @asks = Ask.search_title(params["w"],:limit => 10)
      render :json => @asks.to_json(:only => [:topics,:id,:title])
    else
      @asks = Ask.search_title(params["w"],:limit => 20)
      set_seo_meta("关于“#{params[:w]}”的搜索结果")
      render "index"
    end
  end

  def show
    @ask = Ask.find(params[:id])
    @ask.views_count += 1
    @ask.save
    # 由于 voteable_mongoid 目前的按 votes_point 排序有问题，没投过票的无法排序
    @answers = @ask.answers.includes(:user).sort { |a,b| b.votes_point <=> a.votes_point }
    @answer = Answer.new
    @relation_asks = Ask.normal.any_in(:topics => @ask.topics).excludes(:id => @ask.id).limit(10).desc("$natural")
    set_seo_meta(@ask.title)

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def answer
    @answer = Answer.new(params[:answer])
    @answer.ask_id = params[:id]
    @answer.user_id = current_user.id
    if @answer.save
      @success = true
    else
      @success = false
    end

  end

  def spam 
    @ask = Ask.find(params[:id])
    count = @ask.spam(current_user.id)
    render :text => count
  end
  
  def follow
    @ask = Ask.find(params[:id])
    if params[:follow].blank?
      follow = false
    else
      follow = true
    end
    res = current_user.follow_ask(@ask,follow)
    render :text => res
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
    @ask.user_id = current_user.id
    @ask.followers << current_user

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(ask_path(@ask.id), :notice => '问题创建成功。') }
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
        format.html { redirect_to(ask_path(@ask.id), :notice => '问题更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def update_topic
    @name = params[:name].strip
    @add = params[:add] == "1" ? true : false

    @ask = Ask.find(params[:id])
    if @ask.update_topics(@name,@add)
      @success = true
    else
      @success = false
    end
    if not @add
      render :text => @success
    end
  end

  def mute
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.mute_ask(@ask.id)
    render :text => "1"
  end
  
  def unmute
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.unmute_ask(@ask.id)
    render :text => "1"
  end
  
  def follow
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.follow_ask(@ask)
    render :text => "1"
  end
  
  def unfollow
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.unfollow_ask(@ask)
    render :text => "1"
  end
  
end
