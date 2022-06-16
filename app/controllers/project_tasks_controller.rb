class ProjectTasksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    @users = User.all
    @project_task =  ProjectTask.new
  end

  def edit
    @users = User.all
    @project_task =  ProjectTask.find(params[:id])
  end

  def index
    @project_tasks =  ProjectTask.all
  end

  def show
    @project_task =  ProjectTask.find(params[:id])
  end

  def create
    @project_task =  ProjectTask.new(project_task_params)
    if @project_task.save
      flash[:success] = 'saved'
    else
      flash[:danger] = 'unable to save'
    end
    redirect_to project_tasks_path
  end

  def update
    @project_task =  ProjectTask.find(params[:id])
    if @project_task.update(task_params)
      flash[:success] = 'updated'
    else
      flash[:danger] = 'unable to update'
    end
    redirect_to project_tasks_path
  end

  def destroy
    @project_task =  ProjectTask.find(params[:id])
    if @project_task.destroy
      flash[:success] = 'deleted'
    else
      flash[:danger] = 'unable to delete'
    end
    redirect_to project_tasks_path
  end

  def search_auto_complete_data_tasks
    @projects = Project.order(:name).where("name like ?",  "%#{params[:term]}%")
    render json: @projects.map(&:name)
  end 

  private

  def project_task_params
    params.require(:project_task).permit(:title,:related_to_task, :status, :assigned_to_id, :priority, :start_date, :end_date, :description).merge({assigned_by_id: current_user.id})
  end

end
