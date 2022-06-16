class InvoiceMailer < ApplicationMailer
  default from: ENV['FROM_EMAIL']
  
  def send_invoice(invoice,subject,body)
    @invoice = invoice
    @body = body
    attachments["#{@invoice.invoice_no.to_underscore}_from_#{@invoice.client.company_name}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string('invoices/invoice_details', layout: 'layouts/pdf.html'),
      lowquality: true,
      zoom: 1,
      dpi: 75
    )
    mail(to: @invoice.email, cc: @invoice.cc&.split(","), bcc: @invoice.bcc&.split(","), subject: subject)
  end
end
