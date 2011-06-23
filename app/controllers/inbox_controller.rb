class InboxController < ApplicationController
  def index
    @inboxes = Inbox.find_by_user_id(current_user.id)
  end

  def show
    @inbox = Inbox.find(params[:id])
  end
  
  def new
    @inbox = Inbox.new
    render "new", :layout => false
  end
  
  def create
    @inbox = Inbox.send(current_user.id,params[:to],params[:body])
  end
  
  def reply 
    @inbox = Inbox.find(params[:id])
    @inbox.reply(current_user.id, params[:body])
  end
end
