class ProjectManagement::CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @comments = task.comments
  end

  def create
    if comment.update(comment_params)
      flash.now[:success] = 'Comment Successfully Added!'
    else
      flash.now[:danger] = 'Error Occurred While Adding A Comment!'
    end
  end

  def destroy
    if comment.destroy
      flash.now[:success] = 'Comment Successfully Deleted!'
    else
      flash.now[:danger] = 'Error Occurred While Deleting A Comment!'
    end
  end

  private

  def task
    @task ||= ProjectManagement::Project::Task::find(params[:task_id])
  end

  def comment
    @comment ||= if params[:id].present?
                   ProjectManagement::Project::Task::Comment.find(params[:id])
                 else
                   task.comments.build(created_by: current_user)
                 end
  end

  def comment_params
    params.require(:project_management_project_task_comment).permit(:description)
  end
end
