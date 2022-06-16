class Contacts::ProjectsController < ApplicationController
  layout 'contacts'
  before_action :authenticate_contact!, except: [:accept_contact_invitation]
  before_action :set_klass

  def index
    project_ids = ProjectContact.where(status: true).where(contact_id: current_contact.id).pluck(:project_id)
    @klass = Klass.find_by(name: "Project")
    @fields = @klass.fields.where(header_view: true).reorder(:head_position)
    @projects = Project.where(id: project_ids)
    @clients = Client.where(id: @projects.pluck(:client_id))
  end

  def user_list
    contact_ids = LeadClientContact.where(contactable_id: params[:client_id], contactable_type: 'Client').pluck(:contact_id)
    @contacts = Contact.where(id: contact_ids)
    @client = Client.find(params[:client_id]) if params[:client_id].present?
  end

  def project_details
    @project = Project.find(params[:id])
    @klass = Klass.find_by(name: "Project")
    @overviews = (Message.where(messageable_type: ["Project", "Message"], messageable_id: @project) + @project.project_documents).sort{|a,b| a.created_at <=> b.created_at }
    @project_users = ProjectUser.where(project_id: @project.id)
    @clients = Client.where(id: [@project_users.pluck(:client_id)])
  end


   def show
    #@current_client = Client.find(select_client) #select_client from application controller 
    if params[:message]
      @project = Project.find(params[:id])
      @klass = Klass.find_by(name: "Project")
      @project_users = ProjectUser.where(project_id: @project.id)
      # @clients = Client.where(id: [@project_users.pluck(:client_id)])

    else
      @project = Project.find(params[:id])
      @klass = Klass.find_by(name: "Project")
      @comment = []
      @project.messages.each do |com|
        if com.messages
          com.messages.each do |data|
            @comment << data
          end
        end
      end
      @project.unreads.where(resourcable: current_contact).destroy_all
      # @overviews = (@project.messages +  @comment  + @project.project_documents).sort{|a,b| a.created_at <=> b.created_at }
      @overviews = (@project.messages +  @comment  + @project.document_documentables + @project.messages.map{ |msg| msg.document_documentables}).flatten.sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }

      @project_users = ProjectUser.where(project_id: @project.id)
      #@clients = Client.where(id: [@project_users.pluck(:client_id)])
    end

  end

 def project_user_list
    if current_user.has_role? :super_admin
      @project_users = ProjectUser.all
    else
      @projects = current_user.projects.pluck(:id)
      @project_users = ProjectUser.where(project_id: @projects)
    end
  end


  
  def back_to_project
    @project = Project.find(params[:id])
    @projects = Project.all
    @klass = Klass.find_by(name: "Project")
    @fields = @klass.fields.where(header_view: true).reorder(:head_position)
  end

  def overview
    @project = Project.find(params[:id])
    @projects = Project.all
    @klass = Klass.find_by(name: "Project")
    @fields = @klass.fields.where(header_view: true).reorder(:head_position)
    @comment = []
    @project.messages.each do |com|
      if com.messages
        com.messages.each do |data|
          @comment << data
        end
      end
    end
    # @overviews = (@project.messages +  @comment  + @project.project_documents).sort{|a,b| a.created_at <=> b.created_at }
    @overviews = (@project.messages + @project.document_documentables +  @comment  + @project.messages.map{ |msg| msg.document_documentables}).flatten.sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
  end

  def accept_contact_invitation
    project_contact = ProjectContact.find(params[:project_contact])
    project_contact.update(status: true)
    redirect_to contacts_root_path
  end

  def set_klass
    @klass = Klass.find_by(name: 'Project')
  end

end
