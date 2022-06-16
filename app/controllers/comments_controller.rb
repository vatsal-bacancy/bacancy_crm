class CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:client_id]
      @object = Client.find(params[:client_id])
    elsif params[:lead_id]
      @object = Lead.find(params[:lead_id])
    end
    @comments = @object.comments
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:success] = 'Comment added'
    else
      flash[:danger] = 'Cant add comment'
    end
    respond_to do |format|
        format.js
        format.html {redirect_to @comment.commentable}
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      flash[:success] = 'Updated'
    else
      flash[:danger] = 'Cant update'
    end
    redirect_to @comment.commentable
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :attachment, :commentable_type,:commentable_id).merge(user: current_user)
  end
end
