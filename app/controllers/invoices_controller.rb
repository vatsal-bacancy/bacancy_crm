class InvoicesController < ApplicationController
  before_action :authenticate_user!, except: [:preview, :download, :show]
  before_action :set_klass#, only: [:index, :new, :create, :update, :destroy_all]

  def index
    @klass = Klass.find_by(name: 'Invoice')
    can_perform?(@klass, @action_read)
    @invoices = Invoice.order(id: :desc)
    @fields = current_user.fields_for_table_with_order(klass: @klass)
  end

  def new
    @invoice = Invoice.new
    @invoice.invoice_inventories.build
    @invoice.client_id = params[:client_id] if params[:client_id].present?
    @users = User.all
    @groups = Group.includes(:fields).where(klass: @klass)
  end

  def show
    @invoice = Invoice.find(params[:id])
    redirect_to @invoice.invoice_pdf.document.attachment.url #redirect_to s3
  end

  def edit
    @klass = Klass.find_by(name: 'Invoice')
    @invoice = Invoice.find(params[:id])
  end

  def create
    @invoice = Invoice.new(invoice_params.merge(sales_person: current_user))
    if @invoice.save
      create_document(@invoice, params[:document_ids], params[:attachments],current_user)

      @invoice.update_columns(cc: params[:cc_email],bcc: params[:bcc_email])
      module_number = @klass.module_number
      @invoice.update_columns(invoice_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+@invoice.id-1}")
      document_params = { documentable_type: @invoice.class , documentable_id: @invoice.id }
      @invoice.create_pdf
      redirect_to invoice_email_path(@invoice)
    else
      flash.now[:danger] = @invoice.errors.full_messages.join(', ')
      render "new"
    end
    @fields = current_user.fields_for_table_with_order(klass: @klass)
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.update(invoice_params)
    create_document(@invoice, params[:document_ids], params[:attachments],current_user)
    redirect_to invoice_email_path(@invoice)
  end

  def destroy
    can_perform?(@klass, @action_delete)
    @invoice = Invoice.find(params[:id])
    @invoice.destroy
    @klass = Klass.find_by(name: 'Invoice')
    @invoices = Invoice.order(id: :desc)
    @fields = current_user.fields_for_table_with_order(klass: @klass)
  end

  def destroy_all
    @invoices = Invoice.where(id: params[:ids])
    @invoices.destroy_all
    @invoices = Invoice.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
  end

  def inventories
    @inventories = Inventory.all.select("id, sell_price, tax, name AS text")
    if params[:q]
      @inventories = @inventories.where("lower(name) LIKE ?", "%#{params[:q].try(:downcase)}%")
    end
    render json: {results: @inventories}
  end

  def clients
    @clients = Client.all.select("id, company_name as text, company_email, street_address, city, state, zip_code")
    if params[:q].present?
      @clients = @clients.where('lower(company_name) LIKE ?', "%#{params[:q].try(:downcase)}%")
    end
    render json: {results: @clients}, methods: :full_address
  end

  def email
    @invoice = Invoice.find(params[:invoice_id])
  end

  def email_create
    @invoice = Invoice.find(params[:invoice_id])
    @invoice.send_mail(params[:subject], params[:body])
    if params[:redirect_to] == 'index'
      redirect_to client_path(@invoice.client, invoice: "invoice")
    elsif params[:redirect_to] == 'new'
      redirect_to new_invoice_path(client_id: @invoice.client.id)
    end
  end

  def download
    @invoice = Invoice.find(params[:invoice_id])
    respond_to do |format|
      format.pdf do
        render pdf: "Invoice No. #{@invoice.id}",
        page_size: 'A4',
        template: "invoices/invoice_details",
        layout: "pdf.html",
        lowquality: true,
        zoom: 1,
        dpi: 75,
        disposition: 'attachment'
      end
    end
  end

  def preview
    @invoice = Invoice.find(params[:invoice_id])
    render layout: false
  end

  private

  def invoice_params
    @klass = Klass.find_by(name: "Invoice")
    @groups = @klass.groups.where.not(name: "default_group")
    @field = []
    @groups.each do |group|
      @field << group.fields.pluck(:name)
    end
    params.require(:invoice).permit(multi_select_params_permit(@klass), :client_id,:email, :billing_address, :terms,:msg_on_invoice, :msg_on_statement, :invoice_date, :due_date, :attachment, @field.flatten, invoice_inventories_attributes: {})
  end

  def set_klass
    @klass = Klass.find_by(name: 'Invoice')
    @data ={}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

end
