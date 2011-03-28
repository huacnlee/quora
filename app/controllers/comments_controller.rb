class CommentsController < ApplicationController
  before_filter :require_user_js, :only => [:create]
  def index
    @type = params[:type]
    @id = params[:id]
    @comments = Comment.where(:commentable_type => @type.titleize, :commentable_id => BSON::ObjectId(@id)).to_a
    @comment = Comment.new(:commentable_type => @type.titleize, :commentable_id => @id)
  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.commentable_type = @comment.commentable_type.titleize
    @comment.user_id = current_user.id
    if @comment.save
      @success = true
    else
      @success = false
    end
  end
end
