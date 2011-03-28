# coding: UTF-8
class AsksController < ApplicationController
  
  def index
    @per_page = 10
    @asks = Ask.includes(:user,:last_answer,:last_answer_user,:topics).desc(:id).paginate(:page => params[:page], :per_page => @per_page)
  end

  def show
    @ask = Ask.find(params[:id])
    @answers = @ask.answers.includes(:user).best_voted
    @answer = Answer.new

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
  
  def destroy
    @ask = Ask.find(params[:id])
    @ask.destroy

    respond_to do |format|
      format.html { redirect_to(asks_path,:notice => "问题删除成功。") }
      format.json
    end
  end
end
