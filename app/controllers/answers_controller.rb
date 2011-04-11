class AnswersController < ApplicationController
  before_filter :require_user_text

  def vote
    answer = Answer.find(params[:id])
    vote_type = :down
    if params[:inc] == "1"
      vote_type = :up
    end
    success = answer.vote(:voter_id => current_user.id, :value => vote_type)
    
    if params[:inc] == "1"
      begin
        log = UserLog.new
        log.user_id = current_user.id
        log.target_id = answer.id
        log.action = "AGREE"
        log.target_parent_id = answer.ask.id
        log.target_parent_title = answer.ask.title
        log.diff = ""
        log.save
      rescue Exception => e
      
      end
    end
    
    answer.reload
    render :text => "#{answer.up_votes_count}|#{answer.down_votes_count}"
  end

  def spam
    @answer = Answer.find(params[:id])
    count = @answer.spam(current_user.id)
    render :text => count
  end

  def thank
    @answer = Answer.find(params[:id])
    current_user.thank_answer(@answer)
    render :text => "1"
  end
  
end
