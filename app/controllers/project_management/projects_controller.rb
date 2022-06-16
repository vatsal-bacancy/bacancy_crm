class ProjectManagement::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :fields, :fields_picklist_data

  def index
    projects
  end

  def list
    projects
  end

  def new
    project
    project.set_defaults
  end

  def edit
    project
  end

  def show
    project
  end

  def create
    if project.update(project_params)
      flash[:success] = 'Project Successfully Added!'
    else
      flash[:danger] = 'Error Occurred While Adding A Project!'
    end
    redirect_to request.referer
  end

  def update
    if project.update(project_params)
      flash[:success] = 'Project Successfully Updated!'
    else
      flash[:danger] = 'Error Occurred While Updating A Project!'
    end
    redirect_to request.referer
  end

  def destroy
    if project.destroy
      flash[:success] = 'Project Successfully Deleted!'
    else
      flash[:danger] = 'Error Occurred While Deleting A Project!'
    end
    redirect_to request.referer
  end

  def contacts_form
    project.assign_attributes(client_id: params[:client_id])
  end

  private

  def klass
    @klass ||= ProjectManagement::Project.klass
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

  def projects
    @projects ||= ProjectManagement::Project.all
  end

  def project
    @project ||= if params[:id].present?
                   ProjectManagement::Project.find(params[:id])
                 else
                   ProjectManagement::Project.new(created_by: current_user)
                 end
  end

  def project_params
    params[:project_management_project][:resources_attributes] = (params[:user_ids] || []).map{|user_id| {resourceable_id: user_id, resourceable_type: 'User'}}
                                                                   .concat(project.user_resources.where.not(resourceable_id: params[:user_ids]).map{|user_resource| {id: user_resource.id, _destroy: '1'}})
    params[:project_management_project][:resources_attributes].concat (params[:contact_ids] || []).map{|contact_id| {resourceable_id: contact_id, resourceable_type: 'Contact'}}
                                                                        .concat(project.contact_resources.where.not(resourceable_id: params[:contact_ids]).map{|contact_resource| {id: contact_resource.id, _destroy: '1'}})
    params.require(:project_management_project).permit(fields.pluck(:name), resources_attributes: [:id, :resourceable_id, :resourceable_type, :_destroy])
  end
end
