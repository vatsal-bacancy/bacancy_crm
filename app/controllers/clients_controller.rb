class ClientsController < ApplicationController
  before_action :authenticate_user!

  def new
    @users = current_user.all_user_of_related_company.active
    @client = Client.new(user: current_user)
    @client.contacts.build
    @klass = Klass.find_by(name: "Client")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def index
    @klass = Klass.find_by(name: "Client")
    can_perform?(@klass, @action_read)
    @users = current_user.all_user_of_related_company.active
    @clients = Client.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields_data = Field.where(klass: @klass, have_custom_value: true)
    fields_data.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    respond_to do |format|
      format.js
      format.html
      format.csv { send_data @clients.to_csv, filename: "client-#{Date.today}.csv" }
      format.json do
        render json: ClientDatatable.new(params, objects: @clients, fields: @fields, fields_picklist_data: @data)
      end
    end

  end

  def show
    @client = Client.find(params[:id])
    @users = User.all
    @klass = Klass.find_by(name: "Client")
    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)

    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)

    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)

    @invoice_klass = Klass.find_by(name: "Invoice")
    @invoice_fields = current_user.fields_for_table_with_order(klass: @invoice_klass)

    @project_klass = Klass.find_by(name: 'Project')

    @groups = Group.includes(:fields).where(klass: @klass)
    @comments = @client.comments
    #client picklist value
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    #ticket picklist value
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @note = Note.new
  end

  def create
    @client = Client.new(client_params)
    @klass = Klass.find_by(name: "Client")
    @users = current_user.all_user_of_related_company.active
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields_data = Field.where(klass: @klass, have_custom_value: true)
    fields_data.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    if @client.save
      module_number = @klass.module_number
      @client.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+@client.id-1}")
      if params[:lead_id]
        @lead = Lead.find(params[:lead_id])
        @lead.notes.update_all(noteable_id: @client.id, noteable_type: @client.class.name)
        @lead.tasks.update_all(taskable_id: @client.id, taskable_type: @client.class.name)
        @lead.tickets.update_all(ticketable_id: @client.id, ticketable_type: @client.class.name)
        @lead.file_manager_file_associations.update_all(associable_id: @client.id, associable_type: @client.class.name)
        @lead.lead_client_contacts.update_all(contactable_id: @client.id, contactable_type: @client.class.name)
        @lead.cemails.update_all(cemailable_id: @client.id, cemailable_type: @client.class.name)
        @lead.contracts.update_all(contractable_id: @client.id, contractable_type: @client.class.name)
        @lead.purchase_order_versions.update_all(purchase_orderable_id: @client.id, purchase_orderable_type: @client.class.name)
        @lead.destroy
      end
      if client_contacts_params["contacts_attributes"]
        client_contacts_params["contacts_attributes"].each do |contact, data|
          data.delete("_destroy")
          @contact = Contact.find_or_create_by(data)
          LeadClientContact.create(contact_id: @contact.id, contactable: @client)
          if @contact.portal_invitation
            @contact.send_account_setup_instructions(current_user)
          end
          # end
        end
      end
      flash[:success] = 'Client Successfully Added!'
    else
      flash[:danger] = @client.errors.full_messages.join(",")
      @error = @client.errors.any?
      @client = Client.new(client_params)
      @client.contacts.build
      @users = User.all
      @groups = Group.includes(:fields).where(klass: @klass)
      #render :new
    end
    @clients = Client.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    if @error
      respond_to do |format|

        format.html {redirect_to params[:lead_id].present? ? lead_path(params[:lead_id]) : clients_path }
        format.js
      end
    else
      respond_to do |format|
        format.html {redirect_to client_path(@client)}
        format.js
      end
    end
  end

  def edit
    @users = User.all
    @client = Client.find(params[:id])
    @klass = Klass.find_by(name: "Client")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def edit_summary
    @client = Client.find(params[:id])
    @group = Group.find(params[:group_id])
    @klass = Klass.find_by(name: "Client")
    user_details = User.all.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update
    @client = Client.find(params[:id])
    @note = Note.new
    if @client.update(client_params)
      flash[:success] = 'Client Successfully Updated!'
    else
      flash[:danger] = @client.errors.full_messages.join(",")
    end
    @clients = Client.all.order(:id)
    @klass = Klass.find_by(name: "Client")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    # redirect_to client_path
    @users = User.all
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @klass = Klass.find_by(name: "Client")

    if @client.destroy
      flash[:success] = 'Client Successfully Deleted!'
    else
      flash[:danger] = @client.errors.full_messages.join(",")
    end
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @data = {user_id: User.all.pluck(:first_name, :id)}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @clients = Client.all
  end

  def destroy_all
    @clients = Client.where(id: params[:ids])
    if @clients.destroy_all
      flash[:success] = 'Selected Clients Successfully Deleted!'
    else
      flash[:danger] = 'Something Went Wrong While Deleting Selected Clients!'
    end
    @clients = Client.all
    @klass = Klass.find_by(name: "Client")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
  end

  def import_file_client
    @document = Document.find(params[:document_id])
    @errors = Client.import(@document.attachment, params[:fields].permit!.to_h, @document.id, current_user.id)
    if @errors.present?
      flash[:danger] = @errors.join(",")
    else
      flash[:success] = "CSV Imported Successfully!"
    end
    redirect_to clients_path
  end

  def import_form_client
    #get call for import CSV
    #call js
    respond_to do |format|
      format.js
    end
  end

  def import_map
    @document = Document.create(attachment: params[:import], resourcable: current_user)
    @headers = CSV.open(params[:import].path, encoding: 'iso-8859-1:utf-8', &:readline)
    @klass = Klass.find_by(name: "Client")
    @fields = Field.where(klass: @klass).where("(group_id IS NULL AND column_type = 'Hidden') OR group_id is not NULL")
    @data =  CSV.read(params[:import].path, :headers=>true, encoding: 'iso-8859-1:utf-8')
    @sample_data = @data[0]
    @errors = false
  end

  def import_clients
    @klass = Klass.find_by(name: "Client")
    @import_data_csvs = current_user.import_data_csvs.where(klass_id: @klass.id).order(created_at: :desc)
  end

  def set
    session[:client_id] = params[:client_id]
    redirect_to root_url
  end

  def select_client
    @client_list = current_user.clients
  end

  def logs
    @client = Client.find(params[:id])
  end

  def status_board
    @datatable_options = {}
    if params[:tv].present?
      @datatable_options['autoCycleThroughPageInterval'] = 30000
      @datatable_options['lengthMenu'] = [5]
      @datatable_options['stateSave'] = false
    end
  end

  def department_details
    render json: Client::StatusBoard::DepartmentDetailsDatatable.new(params, view: view_context)
  end

  # handles client update request from status board
  def update_status_board
    @client = Client.find(params[:client_id])
    unless @client.update(client_params)
      flash.now[:danger] = @client.errors.full_messages.to_sentence
    end
  end

  def send_menu_approval_email
    client = Client.find(params[:id])
    MailWorker.perform_async({ to: client.contacts.pluck(:email).join(','),
                               subject: 'Please confirm the Menu',
                               body: render_to_string('menu_approval_email_template', locals: { client: client }, layout: false)
                             })
  end

  def send_menu_approval_sms
    client = Client.find(params[:id])
    SMSWorker.perform_async({ to: client.contacts.pluck(:phone_no).join(','),
                              body: render_to_string('menu_approval_sms_template', locals: { client: client }, layout: false),
                            })
  end

  def client_by_merchant_id
    if params[:merchant_id].present? && (client = Client.find_by("#{Client.merchant_id_attribute} ILIKE :search", search: "%#{params[:merchant_id]}%"))
      redirect_to client
    else
      flash[:danger] = 'Client not found!'
      redirect_to root_path
    end
  end

  private

  def client_params
    @klass = Klass.find_by(name: "Client")
    params.require(:client).permit(@klass.fields.pluck(:name), multi_select_params_permit(@klass))
  end

  def client_contacts_params
    @klass = Klass.find_by(name: "Client")
    params.require(:client).permit(multi_select_params_permit(@klass), contacts_attributes: {})
  end
end
