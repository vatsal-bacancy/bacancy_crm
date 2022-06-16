class InvoiceWorker
  include Sidekiq::Worker

  def perform(method, opts={})
    self.send(method, opts.with_indifferent_access)
  end

  def create_pdf(opts)
    invoice = Invoice.find(opts[:invoice_id])
    if invoice.invoice_pdf
      # called if invoice paid
      old_document = invoice.invoice_pdf.document
      new_document = create_pdf_document(invoice)
      invoice.invoice_pdf.document_documentable.update(document: new_document)
      old_document.destroy
    else
      # called when invoice build for first time
      invoice_pdf = InvoicePdf.create(invoice: invoice)
      document = create_pdf_document(invoice)
      DocumentDocumentable.create(document: document, documentable: invoice_pdf)
    end
  end

  def send_mail(opts)
    InvoiceMailer.send_invoice(Invoice.find(opts[:invoice_id]), opts[:subject], opts[:body]).deliver
  end

  private

  def create_pdf_document(invoice)
    filename = "#{invoice.invoice_no.to_underscore}_from_#{invoice.client.company_name}"
    str = ApplicationController.new.render_to_string(pdf: filename, template: 'invoices/invoice_details.pdf.erb', layout: "pdf.html", encoding: "UTF-8", locals: {:@invoice => invoice})
    tmpfile = File.open(Rails.root.join("tmp/#{filename}.pdf"), 'wb')
    tmpfile.write(str)
    document = Document.create(attachment: tmpfile)
    tmpfile.close
    document
  end
end
