class ProjectManagement::TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :fields, :fields_picklist_data

  def new
    task
    task.set_defaults
  end

  def edit
    task
  end

  def show
    task
  end

  def create
    if task.update(task_params)
      flash[:success] = 'Task Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Task!'
    end
    redirect_to project_management_project_path(task.project)
  end

  def update
    if task.update(task_params)
      flash[:success] = 'Task Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Task!'
    end
    redirect_to project_management_project_path(task.project)
  end

  def destroy
    if task.destroy
      flash[:success] = 'Task Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Task!'
    end
    redirect_to project_management_project_path(task.project)
  end

  private

  def klass
    @klass ||= ProjectManagement::Project::Task.klass
  end

  def fields
    @fields ||= klass.fields
  end

  def fields_picklist_data
    @fields_picklist_data ||= begin
                                klass.fields.field_picklist_valuable.includes(:field_picklist_values).inject({}.with_indifferent_access) do |hash, field|
                                  hash[field.name] = field.field_picklist_values.pluck(:value)
                                  hash
                                end
                              end
  end

  def task
    @task ||= if params[:id].present?
                ProjectManagement::Project::Task.find(params[:id])
              else
                ProjectManagement::Project.find(params[:project_id]).tasks.build(project_id: params[:project_id], created_by: current_user)
              end
  end

  def task_params
    params.require(:project_management_project_task).permit(fields.pluck(:name))
  end
end
