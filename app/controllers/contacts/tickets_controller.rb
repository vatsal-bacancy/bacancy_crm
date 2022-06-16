class Contacts::TicketsController < ApplicationController
  layout 'contacts'
  before_action :authenticate_contact!


  def index
    #@tickets = Ticket.all
    if params[:ticketable_type] == 'Lead'
      @object = Lead.find(params[:ticketable_id])
    end
    @tickets =  current_contact.associated_tickets.order(created_at: :desc) # current_contact.lead_client_contact.contactable.tickets.order(id: :desc)
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = @ticket_klass.fields.where(header_view: true).reorder(:head_position)
    @data = nil
    @from_page = 'index'
  end

  def new
    @ticket = Ticket.new(ticketable_type: params[:ticketable_type], ticketable_id: params[:ticketable_id])
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
    @ticket = Ticket.new(ticket_params)
    @ticket.ticketable_type =  params[:ticket][:ticketable].split(":")[0]
    @ticket.ticketable_id =  params[:ticket][:ticketable].split(":")[1]
    @data = nil
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = @ticket_klass.fields.where(header_view: true).reorder(:head_position)

    if @ticket.ticketable_type == "Lead"
      @object = Lead.find( @ticket.ticketable_id )
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find( @ticket.ticketable_id )
    end

    if @ticket.save
      module_number = @ticket_klass.module_number
      @ticket.update_attributes(ticket_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+@ticket.id-1}")
      if params[:ticket][:attachment].present?
        document_params = { documentable_type: @ticket.class , documentable_id: @ticket.id }
        params[:ticket][:attachment].each do |attachment|
          @document = Document.new(document_params.merge({user_id: current_user.id, attachment: attachment}))
          @document.save
        end
      end
      flash[:success] = "Successfully added"
    else
      flash[:danger] = "Enable to add "
    end
    @tickets = Ticket.order(:id)
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
    @ticket.ticketable_type =  params[:ticket][:ticketable].split(":")[0]
    @ticket.ticketable_id =  params[:ticket][:ticketable].split(":")[1]
    @data = nil
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = @ticket_klass.fields.where(header_view: true).reorder(:head_position)

    if @ticket.ticketable_type == "Lead"
      @object = Lead.find( @ticket.ticketable_id )
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find( @ticket.ticketable_id )
    end
    if @ticket.update(ticket_params)
      if params[:ticket][:attachment].present?
        document_params = { documentable_type: @ticket.class , documentable_id: @ticket.id }
        params[:ticket][:attachment].each do |attachment|
          @document = Document.new(document_params.merge({user_id: current_user.id, attachment: attachment}))
          @document.save
        end
      end
      flash[:success] = "Successfully updated"
    else
      flash[:danger] = "Enable to edit "
    end
    @tickets = Ticket.order(created_at: :desc)
  end

  def show
    @ticket = Ticket.find(params[:id])
    @ticket.unreads.where(resourcable: current_contact).destroy_all #mark ticket as readed
    @klass = Klass.find_by(name: "Ticket")

    @overviews = (@ticket.messages).sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
    @document = [ @ticket => @ticket.document_documentables] + @ticket.messages.map{ |msg| {msg => msg.document_documentables} }  
    @ticket_users = TicketUser.where(ticket_id: @ticket.id)
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = @ticket_klass.fields.where(header_view: true).reorder(:head_position)
    @data = nil
    if @ticket.ticketable_type == "Lead"
      @object = Lead.find( @ticket.ticketable_id )
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find( @ticket.ticketable_id )
    end

    if @ticket.destroy
      flash[:success] = "successfully deleted"
    else
      flash[:danger] = "Enable to delete"
    end
    @tickets = Ticket.order(:id)
  end

  def destroy_all
    @tickets = Ticket.where(id: params[:ids])
    if params[:ticketable_type] == "Lead"
      @object = Lead.find(params[:ticketable_id])
    elsif params[:ticketable_type] == "Client"
      @object = Client.find(params[:ticketable_id])
    end
    if @tickets.destroy_all
      flash[:success] = "Successfully deleted"
    else
      flash[:denger] = "Enable to delete"
    end
    @tickets = Ticket.order(:id)
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = @ticket_klass.fields.where(header_view: true).reorder(:head_position)
  end

  def back_to_ticket
    @ticket = Ticket.find(params[:id])
    if @ticket.ticketable_type == "Lead"
      @object = Lead.find(@ticket.ticketable_id)
    elsif @ticket.ticketable_type == "Client"
      @object = Client.find(@ticket.ticketable_id)
    end
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = @ticket_klass.fields.where(header_view: true).reorder(:head_position)
  end

  def autocomplete_data
    @leads = Lead.order(:company_name).where("company_name like ?",  "%#{params[:term]}%")
    render json: @leads.map(&:company_name)
  end

  def overview
    @ticket = Ticket.find(params[:id])
    @tickets = Ticket.all
    @klass = Klass.find_by(name: "Ticket")
    @fields = @klass.fields.where(header_view: true).reorder(:head_position)
    # @overviews = (@project.messages +  @comment  + @project.project_documents).sort{|a,b| a.created_at <=> b.created_at }
    @overviews = (@ticket.messages).sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
  end

  private
  def ticket_params
    @klass = Klass.find_by(name: "Ticket")
    params.require(:ticket).permit(@klass.fields.pluck(:name))
  end
end
