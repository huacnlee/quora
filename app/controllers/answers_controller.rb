class AnswersController < ApplicationController
  before_filter :require_user_text

  def vote
    answer = Answer.find(params[:id])
    vote_type = :down
    if params[:inc] == "1"
      vote_type = :up
    end
    success = answer.vote(:voter_id => current_user.id, :value => vote_type)
    answer.reload
    render :text => "#{answer.up_votes_count}|#{answer.down_votes_count}"
  end
end
