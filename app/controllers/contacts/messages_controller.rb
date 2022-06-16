class Contacts::MessagesController < ApplicationController
  layout 'contacts'
  before_action :authenticate_contact!

  def index
    if params[:message_id] && params[:project_id]
      @object = Project.find(params[:project_id])
      @message = Message.find(params[:message_id])
    elsif params[:message_id] && params[:ticket_id]
      @object = Ticket.find(params[:ticket_id])
      @message = Message.find(params[:message_id])
    elsif params[:ticket_id]
      @object = Ticket.find(params[:ticket_id])
      @messages = @object.messages
    elsif params[:project_id]
      @object = Project.find(params[:project_id])
      @messages = @object.messages
    end
  end

  def new
    # @users = current_user.all_user_of_related_company.active
    # user_details = @users.pluck(:first_name, :id)
    @data = {}
    @message = Message.new
    @klass = Klass.find_by(name: "Message")
    @groups = Group.includes(:fields).where(klass: @klass)
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    if params[:project_id].present?
      @object = Project.find(params[:project_id])
    elsif params[:ticket_id].present?
      @object = Ticket.find(params[:ticket_id])
    elsif params[:message_id].present?
      @object = Message.find(params[:message_id])
    end
    @message = @object.messages.build
  end

  def create
    @klass = Klass.find_by(name: "Message")
    # @users = current_user.all_user_of_related_company.active
    # user_details = @users.pluck(:first_name, :id)
    @data = {}
    fields_data = Field.where(klass: @klass, have_custom_value: true)
    fields_data.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    if params[:project_id].present?
      @object = Project.find(params[:project_id])
      @message =@object.messages.build(message_params)
    elsif params[:ticket_id].present?
      @object = Ticket.find(params[:ticket_id])
      @message =@object.messages.build(message_params)
    elsif params[:message_id].present?
      @message = Message.find(params[:message_id])
      @object = @message.messageable
      @message =@message.messages.build(message_params)
    end
    @message.resourcable = current_contact
    if @message.save
      if params[:document_ids].present?
        params[:document_ids].split(',').each do |document_id|
          @message.document_documentables.create(document_id: document_id,resourcable: current_contact)
          @object.document_documentables.create(document_id: document_id,resourcable: current_contact) if @object.class.name != "Ticket" && @object.class.name != "Project"
        end
      end
      @messages = @object.messages.reorder(created_at: :desc)
    end
    @message.send_project_message_email(@message.id, @message.resourcable_type ) #send email

    respond_to do |format|
      # format.js
      #format.html {redirect_to project_message_path(@object, @message.messageable)}
      if params[:commit] == "Post Comment"
        format.html {redirect_to @object.class.name == 'Project' ? contacts_project_message_path(@object, @message.messageable): contacts_ticket_message_path(@object, @message.messageable)}
      else
        format.html {redirect_to @object.class.name == 'Project' ? contacts_project_path(@object): contacts_ticket_path(@object) }
      end
    end
  end

  def show
    @message = Message.find(params[:id])
    @message_user = @message.resourcable
    @project_users = ProjectUser.where(project_id: params[:project_id])
    @users = User.where(id: [@project_users.pluck(:user_id)])
    # @clients = Client.where(id: [@project_users.pluck(:client_id)])
  end

  def edit
    @message = Message.find(params[:id])
    @messageable = @message.messageable
    if params[:project_id].present?
      @object = Project.find(params[:project_id])
    elsif params[:message_id].present?
      @message_id = Message.find(params[:message_id])
      @object = @message_id.messageable
    end
    @users = current_contact.lead_client_contact.contactable.contacts
    @klass = Klass.find_by(name: "Message")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update
    @message = Message.find(params[:id])
    @message_klass = Klass.find_by(name: "Message")
    @message_fields = @message_klass.fields.where(header_view: true).reorder(:head_position)
    if params[:project_id].present?
      @object = Project.find(params[:project_id])
    elsif params[:message_id].present?
      @message_id = Message.find(params[:message_id])
      @object = @message_id.messageable
    end
    if @message.update(message_params)
      if params[:document_ids].present?
        @message_documentables = @message.document_documentables
        @object_documentables = @object.document_documentables
        params[:document_ids].split(',').each do |document_id|
          @message.document_documentables.find_or_create_by(document_id: document_id, resourcable: current_contact)
          @object.document_documentables.find_or_create_by(document_id: document_id, resourcable: current_contact) if @object.class.name != "Ticket" && @object.class.name != "Project"
        end
        #@message_documentables.where.not(document_id: params[:document_ids].split(',')).destroy_all
      end
      flash[:success] = 'Message update'
    else
      flash[:danger] = 'Cant update message'
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @object = @message.messageable
    @message.destroy
    @object = @object.messageable if @object.class.name == "Message"
    @messages = @object.messages
    respond_to do |format|
      format.js
      format.html {redirect_to project_message_path(@object)}
    end
  end

  def comment_delete
    @comment = Message.find(params[:format])
    @comment.destroy
    @message = Message.find(params[:message_id])
    @project = Project.find(params[:project_id])

  end

  def reply_edit
    #TICKET REPLY EDIT
    @ticket = Ticket.find(params[:ticket_id])
    @message = Message.find(params[:message_id])
  end

  def reply_update
    #TICKET REPLY UPDATE
    @message = Message.find(params[:message_id])
    @ticket = Ticket.find(params[:ticket_id])
    @message.update(message_params)
    if params[:document_ids].present?
      params[:document_ids].split(',').each do |document_id|
        @message.document_documentables.create(document_id: document_id,resourcable: current_contact)
        #@object.document_documentables.create(document_id: document_id) if @object.class.name != "Ticket" && @object.class.name != "Project"
      end
    end
    @klass = Klass.find_by(name: "Ticket")
    @overviews = (@ticket.messages  + @ticket.document_documentables).sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }

    redirect_to contacts_ticket_path(@ticket)
  end

  def reply_delete
    #TICKET REPLY DELETE
    @ticket = Ticket.find(params[:ticket_id])
    if params[:object] == "Message"
      @message = Message.find(params[:message_id])
      @message.destroy
    elsif params[:object] == "Document"
      @document = @ticket.document_documentables.find(params[:message_id])
      @document.destroy
    end

    @klass = Klass.find_by(name: "Ticket")
    @overviews = (@ticket.messages  + @ticket.document_documentables).sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }

    redirect_to contacts_ticket_path(@ticket)
  end


  private
   def message_params
    @klass = Klass.find_by(name: "Message")
    params.require(:message).permit(@klass.fields.pluck(:name), :messageable_type, :messageable_id)
  end
end
