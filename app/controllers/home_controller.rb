class HomeController < ApplicationController
  before_filter :require_user_text, :only => [:update_in_place]

  def index
    @per_page = 10
    @asks = Ask.includes(:user,:last_answer,:last_answer_user,:topics)
                  .desc(:answered_at,:id)
                  .paginate(:page => params[:page], :per_page => @per_page)
  end

  def update_in_place
    klass, field, id = params[:id].split('__')
    object = klass.camelize.constantize.find(id)
    if object.update_attributes(field => params[:value])
      render :text => object.send(field).to_s
    else
      render :text => object.errors.full_messages.join("\n"), :status => 422
    end
  end
end
