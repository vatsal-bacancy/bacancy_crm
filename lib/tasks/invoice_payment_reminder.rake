namespace :invoice_payment_reminder do
  desc "Send email to unpaid invoice"
  task send_payment_reminder: :environment do
    #do somthing
    puts 'call this send payment reminder task every monday'
    @invoices = Invoice.all
    @invoices.each do |invoice|
      unless (Payment.where(invoice_id: invoice.id).find_by(successful: true))
        InvoiceWorker.perform_async(:send_mail, invoice_id: invoice.id, subject: "Reminder for your invoice", body: "")
      end
    end
    puts 'see log latest'
  end

end
