class InboxController < ApplicationController
  def index
    @inboxes = current_user.inboxes
  end

  def show
    @inbox = Inbox.find(params[:id])
  end
  
  def new
    @inbox = Inbox.new
  end
  
  def create
    @inbox = Inbox.send(current_user.id,params[:to],params[:body])
  end
  
  def reply 
    @inbox = Inbox.find(params[:id])
    @inbox.reply(current_user.id, params[:body])
  end
end
