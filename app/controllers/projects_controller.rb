class ProjectsController < ApplicationController
  before_action :authenticate_user!, except: [:accept_user_invitation]
  before_action :set_klass
  load_and_authorize_resource

  def index
    @klass = Klass.find_by(name: 'Project')
    can_perform?(@klass, @action_read)
    project_ids = ProjectUser.where(status: true).where(user_id: current_user.id).pluck(:project_id)
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @projects = Project.where(id: project_ids)
    @clients = Client.where(id: @projects.pluck(:client_id))
  end

  def new
    can_perform?(@klass, @action_create)
    @project = Project.new
    #@current_client = Client.find(select_client)  #select_client from application controller
    @data = {user_id: current_user.id}
    @groups = Group.includes(:fields).where(klass: @klass)

    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    if params[:object]
      object = params[:object].split(':')
      @project.send("#{object[0].to_underscore}_id=", object[1])
    end
  end

  def list
    if current_user.has_role? :super_admin
      @projects = Project.all
    else
      @projects = current_user.projects
    end
  end

  def user_list
    @client = Client.find(params[:client_id])
    @contacts = @client.contacts
    @project_contact_ids = []
    if params[:project_id].present?
      @project_contact_ids = Project.find(params[:project_id]).contact_ids
    end
  end

  def project_details
    @project = Project.find(params[:id])
    @overviews = (Message.where(messageable_type: ["Project", "Message"], messageable_id: @project) + @project.documents).sort{|a,b| a.created_at <=> b.created_at }
    @project_users = ProjectUser.where(project_id: @project.id)
    @clients = Client.where(id: [@project_users.pluck(:client_id)])
  end

  def create
    can_perform?(@klass, @action_create)
    @project = Project.new(project_params)
    @data = {}
    #@current_client = Client.find(select_client) #select_client from application controller
    @groups = Group.includes(:fields).where(klass: @klass)
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    if @project.save
      create_document(@project, params[:document_ids], params[:attachments],current_user)
      #@clients = Client.where(id: @project.id)
      @project.project_users.create(user_id: current_user.id, status: true)

      if params[:user_ids].present?
        #current company user create
        params[:user_ids].each do |user_id|
          @project.project_users.create(user_id: user_id, status: true)
        end
      end
      if params[:contact_ids].present?
        #select company contact create
        params[:contact_ids].each do |contact_id|
          @project.project_contacts.create(contact_id: contact_id, client_id: params[:project][:client_id], status: true)
        end
      end
      @project.find_project_users(params, @project, current_user) #email send form model
      flash[:success] = 'Project successfully added'
    else
      flash[:danger] = @project.errors.full_message.join(",")
    end
   
    if params[:object]
      object = params[:object].split(':')
      @object = object[0].constantize.find(object[1])
      @projects = @object.projects
    else
      @projects = current_user.projects
    end
  end

  def show
    can_perform?(@klass, @action_read)
    #@current_client = Client.find(select_client) #select_client from application controller
    if params[:message]
      @project = Project.find(params[:id])
      @project_users = ProjectUser.where(project_id: @project.id)
      #@clients = Client.where(id: [@project_users.pluck(:client_id)])
    else
      @project = Project.find(params[:id])

      @comment = []
      @project.messages.each do |com|
        if com.messages
          com.messages.each do |data|
            @comment << data
          end
        end
      end
      @project.unreads.where(resourcable: current_user).destroy_all
      @overviews = (@project.messages + @project.document_documentables +  @comment  + @project.messages.map{ |msg| msg.document_documentables}).flatten.sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
      # @project.messages.map{ |msg| msg.document_documentables}
      @project_users = ProjectUser.where(project_id: @project.id)
      #@clients = Client.where(id: [@project_users.pluck(:client_id)])
    end

  end

  def edit
    can_perform?(@klass, @action_update)
    @project = Project.find(params[:id])
    @project.project_assignees.build if params[:assign_project] && @project.project_assignees.blank?
    @groups = Group.includes(:fields).where(klass: @klass)
    @data = {}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update
    can_perform?(@klass, @action_update)
    @project = Project.find(params[:id])
    if @project.update(project_params)
      create_document(@project, params[:document_ids], params[:attachments],current_user)
      if params[:contact_ids].present?
        @project_contacts = @project.project_contacts
        params[:contact_ids].each do |contact_id|
          @project.project_contacts.find_or_create_by(contact_id: contact_id, client_id: params[:project][:client_id], status: true)
        end
        @project_contacts.where.not(contact_id: params[:contact_ids]).destroy_all
      end
      flash[:success] = "Project successfully updated"
    else
      flash[:danger] = @project.errors.full_message.join(",")
    end
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    if params[:object]
      object = params[:object].split(':')
      @object = object[0].constantize.find(object[1])
      @projects = @object.projects
    else
      @projects = current_user.projects
    end
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      flash[:success] = "Project successfully deleted"
    else
      flash[:danger] = @project.errors.full_message.join(",")
    end
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    if params[:object]
      object = params[:object].split(':')
      @object = object[0].constantize.find(object[1])
      @projects = @object.projects
    else
      @projects = current_user.projects
    end
  end

  def send_project_invitaiton
    @project = Project.find(params[:project_id])
    if params[:user_ids].present?
      user_ids = @project.users.ids
      new_user_ids = params[:user_ids].map(&:to_i) - user_ids
      removed_ids = user_ids - params[:user_ids].map(&:to_i)
      @project.project_users.where(user_id: removed_ids).destroy_all
      new_user_ids.each do |user_id|
        @project_user = @project.project_users.create(user_id: user_id, status: true)
        InvitationWorker.perform_async(:project_user_invitation, current_user: current_user.id, user_id: user_id, project_id: @project.id, project_user_id: @project_user.id, login_status: true)
      end
    else
      @project.project_users.destroy_all
    end
    if params[:contact_ids].present?
      contact_ids = @project.contacts.ids
      new_contact_ids = params[:contact_ids].map(&:to_i) - contact_ids
      removed_ids = contact_ids - params[:contact_ids].map(&:to_i)
      @project.project_contacts.where(contact_id: removed_ids).destroy_all
      new_contact_ids.each do |contact_id|
        @project_contact = @project.project_contacts.create(contact_id: contact_id, status: true)
        InvitationWorker.perform_async(:project_contact_invitation, current_user: current_user.id, contact_id: contact_id, project_id: @project.id, project_contact_id: @project_contact.id)
      end
    else
      @project.project_contacts.destroy_all
    end
  end

  def invite_for_project
    @contacts = @project.client.contacts
    @users = User.all
  end

  def project_user_list
    if current_user.has_role? :super_admin
      @project_users = ProjectUser.all
    else
      @projects = current_user.projects.pluck(:id)
      @project_users = ProjectUser.where(project_id: @projects)
    end
  end

  def destroy_all
    @projects = Project.where(id: params[:ids])
    if @projects.destroy_all
      flash[:success] = "Successfully delete all"
    else
      flash[:danger] = "Enable to delete all"
    end
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    if params[:object]
      object = params[:object].split(':')
      @object = object[0].constantize.find(object[1])
      @projects = @object.projects
    else
      @projects = current_user.projects
    end
  end

  def back_to_project
    @project = Project.find(params[:id])
    @projects = Project.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
  end

  def overview
    @project = Project.find(params[:id])
    @projects = Project.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @comment = []
    @project.messages.each do |com|
      if com.messages
        com.messages.each do |data|
          @comment << data
        end
      end
    end
    @overviews = (@project.messages + @project.document_documentables +  @comment  + @project.messages.map{ |msg| msg.document_documentables}).flatten.sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
  end

  def project_communication_dashborad
  end

  def accept_user_invitation
    project_user = ProjectUser.find(params[:project_user])
    project_user.update(status: true)
    redirect_to root_path
  end

  private

  def project_params
    params.require(:project).permit(:name, :status, :start_date, :end_date, :description, :user_id, :client_id,  project_assignees_attributes: %i[id email title company _destroy])
  end

  def set_klass
    @klass = Klass.find_by(name: 'Project')
  end
end
