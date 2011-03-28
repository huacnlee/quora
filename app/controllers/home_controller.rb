class HomeController < ApplicationController
  def index
    @per_page = 10
    @asks = Ask.includes(:user,:last_answer,:last_answer_user,:topics)
          .desc(:answered_at,:id)
          .paginate(:page => params[:page], :per_page => @per_page)
  end
end
