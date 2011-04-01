# coding: UTF-8
class Cpanel::AnswersController < CpanelController
  
  def index
    @answers = initialize_grid(Answer, 
      :order => 'id',
      :order_direction => 'desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @answer = Answer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @answer = Answer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @answer = Answer.find(params[:id])
  end
  
  def create
    @answer = Answer.new(params[:answer])

    respond_to do |format|
      if @answer.save
        format.html { redirect_to(cpanel_answers_path, :notice => 'Answer 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @answer = Answer.find(params[:id])

    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        format.html { redirect_to(cpanel_answers_path, :notice => 'Answer 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_answers_path,:notice => "删除成功。") }
      format.json
    end
  end
end
