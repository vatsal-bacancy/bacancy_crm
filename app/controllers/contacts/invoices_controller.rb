class Contacts::InvoicesController < ApplicationController
  layout 'contacts'

  before_action :authenticate_contact!, except: [:preview, :download, :show]
  before_action :set_klass#, only: [:index, :new, :create, :update, :destroy_all]

  def index
    @invoices = current_contact.lead_client_contact.contactable.invoices.order(id: :desc)
    @fields = @klass.fields.where(header_view: true).reorder(:head_position)
  end

  def show
    @invoice = Invoice.find(params[:id])
    @invoice.unreads.where(resourcable: current_contact).destroy_all
    redirect_to @invoice.invoice_pdf.document.attachment.url #redirect_to s3
  end

  def email
    @invoice = Invoice.find(params[:invoice_id])
  end

  def email_create
    @invoice = Invoice.find(params[:invoice_id])
    filename = "invoice_#{@invoice.id}"
    # pdf = render_to_string pdf: filename, template: 'invoices/report', encoding: "UTF-8"
    # then save to a file
    # save_path = Rails.root.join('public/pdfs',"#{filename}.pdf")
    # File.open(save_path, 'wb') do |file|
    #   file << pdf
    # end
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
    #pdf = @invoice.invoice_pdf.document.attachment
    #@thumbnail = Base64.encode64(Magick::Image.from_blob(pdf.read)[0].to_blob)
    render layout: false
  end

  private

  def invoice_params
    @klass = Klass.find_by(name: 'Invoice')
    params.require(:invoice).permit(:client_id,:email, :billing_address, :terms,:msg_on_invoice, :msg_on_statement, :invoice_date, :due_date, :attachment, invoice_inventories_attributes: {})
  end

  def set_klass
    @klass = Klass.find_by(name: 'Invoice')
  end

end
