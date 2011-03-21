class AnswersController < ApplicationController
  def vote
    answer = Answer.find(params[:id])
    inc = false
    if params[:inc] == "1"
      inc = true
    end
    answer.vote(inc,current_user)
    render :text => answer.votes_count
  end
end
