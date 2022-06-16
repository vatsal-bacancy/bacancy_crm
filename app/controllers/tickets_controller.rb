class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_klass

  def index
    @ticket_klass = Klass.find_by(name: "Ticket")
    can_perform?(@ticket_klass, @action_read)
    if params[:ticketable_type] == 'Lead'
      @object = Lead.find(params[:ticketable_id])
    end
    @tickets =  current_user.has_role?(:super_admin) ?
      Ticket.order(created_at: :desc) : current_user.associated_tickets.order(created_at: :desc)
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @from_page = 'index'
    respond_to do |format|
      format.js
      format.html
      format.json do
        render json: TicketDatatable.new(params, objects: @tickets, fields: @ticket_fields, fields_picklist_data: @ticket_data, view: view_context)
      end
    end
  end

  def new
    @ticket = Ticket.new(ticketable_type: params[:ticketable_type], ticketable_id: params[:ticketable_id])
    @ticket.ticket_users.build(user: current_user)
    @users = User.all.active
    @ticketable = @ticket.ticketable
    @leads = Lead.all.map{|x| [x.company_name, "Lead:#{x.id}"]}
    @clients = Client.all.map{|x| [x.company_name, "Client:#{x.id}"]}
    @grouped_options = { "Leads" => @leads, "Clients" => @clients }
    @klass = Klass.find_by(name: "Ticket")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def create
    @ticket = Ticket.new(ticket_params.merge(owner: current_user))
    @ticket.ticketable_type =  params[:ticket][:ticketable].split(":")[0]
    @ticket.ticketable_id =  params[:ticket][:ticketable].split(":")[1]
    @data = nil
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
    if @ticket.ticketable_type == "Lead"
      @object = Lead.find( @ticket.ticketable_id )
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find( @ticket.ticketable_id )
    end
    if @ticket.save
      module_number = @ticket_klass.module_number
      @ticket.update_attributes(ticket_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+@ticket.id-1}")
      if params[:user_ids].present?
        params[:user_ids].each do |user_id|
          @ticket.ticket_users.create(user_id: user_id)
        end
      end
      if params[:contact_ids].present?
        params[:contact_ids].each do |contact_id|
          @ticket.ticket_contacts.create(contact_id: contact_id)
        end
      end
      create_document(@ticket, params[:document_ids], params[:attachments],current_user)
      @ticket.send_mail #send email
      flash[:success] = 'Ticket Successfully Added!'
    else
      flash[:danger] = @ticket.errors.full_message.join(",")
    end
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @tickets =  current_user.has_role?(:super_admin) ?
      Ticket.order(created_at: :desc) : current_user.associated_tickets.order(created_at: :desc)
    if params[:ticket][:ticket].present?
      redirect_to tickets_path
    end
  end

  def edit
    @ticket = Ticket.find(params[:id])
    @users = User.all.active
    @ticketable = @ticket.ticketable
    @leads = Lead.all.map{|x| [x.company_name, "Lead:#{x.id}"]}
    @clients = Client.all.map{|x| [x.company_name, "Client:#{x.id}"]}
    @grouped_options = { "Leads" => @leads, "Clients" => @clients }
    @klass = Klass.find_by(name: "Ticket")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update
    @ticket = Ticket.find(params[:id])
    if params[:ticket][:ticketable]
      @ticket.ticketable_type =  params[:ticket][:ticketable].split(":")[0]
      @ticket.ticketable_id =  params[:ticket][:ticketable].split(":")[1]
    end
    @data = nil
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
    if @ticket.ticketable_type == "Lead"
      @object = Lead.find( @ticket.ticketable_id )
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find( @ticket.ticketable_id )
    end
    if @ticket.update(ticket_params)
      if params[:contact_ids].present?
        #select company contact create
        @ticket.ticket_contacts.destroy_all
        params[:contact_ids].each do |contact_id|
          @ticket.ticket_contacts.create(contact_id: contact_id)
        end
      end
      if params[:user_ids].present?
        #current company user create
        @ticket.ticket_users.destroy_all
        params[:user_ids].each do |user_id|
          @ticket.ticket_users.create(user_id: user_id)
        end
      end
      create_document(@ticket, params[:document_ids], params[:attachments],current_user)
      flash[:success] = 'Ticket Successfully Updated!'
    else
      flash[:danger] = @ticket.errors.full_message.join(",")
    end
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @tickets =  current_user.has_role?(:super_admin) ?
      Ticket.order(created_at: :desc) : current_user.associated_tickets.order(created_at: :desc)
    if params[:ticket][:ticket].present?
      redirect_to tickets_path
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
    @ticket.unreads.where(resourcable: current_user).destroy_all #mark ticket as readed
    @klass = Klass.find_by(name: "Ticket")
    if params[:message]
      @ticket = Ticket.find(params[:id])
      @ticket_users = TicketUser.where(ticket_id: @ticket.id)
    else
      @ticket = Ticket.find(params[:id])
      @overviews = (@ticket.messages).sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
      @document = [ @ticket => @ticket.document_documentables] + @ticket.messages.map{ |msg| {msg => msg.document_documentables} } 
      @ticket_users = TicketUser.where(ticket_id: @ticket.id)
    end
  end


  def overview
    @ticket = Ticket.find(params[:id])
    @tickets = Ticket.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @overviews = (@ticket.messages).sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
    @data = nil
    if @ticket.ticketable_type == "Lead"
      @object = Lead.find( @ticket.ticketable_id )
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find( @ticket.ticketable_id )
    end
    if @ticket.destroy
      flash[:success] = 'Ticket Successfully Deleted!'
    else
      flash[:danger] = @ticket.errors.full_message.join(",")
    end
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @tickets =  current_user.has_role?(:super_admin) ?
      Ticket.order(created_at: :desc) : current_user.associated_tickets.order(created_at: :desc)
  end

  def destroy_all
    @tickets = Ticket.where(id: params[:ids])
    if params[:ticketable_type] == "Lead"
      @object = Lead.find(params[:ticketable_id])
    elsif params[:ticketable_type] == "Client"
      @object = Client.find(params[:ticketable_id])
    end
    if @tickets.destroy_all
      flash[:success] = 'Selected Tickets Successfully Deleted!'
    else
      flash[:danger] = 'Something Went Wrong While Deleting Selected Ticket!'
    end
    @tickets = Ticket.order(created_at: :desc)
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def back_to_ticket
    @ticket = Ticket.find(params[:id])
    if @ticket.ticketable_type == "Lead"
      @object = Lead.find(@ticket.ticketable_id)
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find(@ticket.ticketable_id)
    end
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
  end

  def autocomplete_data
    @leads = Lead.order(:company_name).where("company_name like ?",  "%#{params[:term]}%")
    render json: @leads.map(&:company_name)
  end

  def contacts_list
    @ticket = Ticket.find_by(id: params[:ticket_id])
    ticketable = params[:ticketable].split(':')
    @ticketable = ticketable[0].constantize.find(ticketable[1])
  end

  def reports
    users = User.all_active_users.joins(:associated_tickets).includes(:associated_tickets)
    if params[:user_ids].present?
      users = users.where(id: params[:user_ids])
    end
    if params[:start_date].present?
      users = users.where('tickets.created_at > ?', DateTime.parse(params[:start_date]))
    end
    users = users.distinct
    ticket_statuses = Ticket.valid_statuses.pluck(:value)
    @tickets = users.inject({}) do |user_hash, user|
      user_hash[user] = {late: user.associated_tickets.select(&:late?).count}
      user_hash[user][:tickets] = ticket_statuses.inject({}) do |hash, status|
        hash[status] = user.associated_tickets.select{|ticket| ticket.status == status}.count
        hash
      end
      user_hash
    end
  end

  def download_attachment
    download = open(params[:url])
    send_file(download, filename: params[:filename])
  end

  private

  def ticket_params
    @klass = Klass.find_by(name: "Ticket")
    params.require(:ticket).permit(@klass.fields.pluck(:name), multi_select_params_permit(@klass))
  end

  def set_klass
    @klass = Klass.find_by(name: 'Ticket')
  end
end
