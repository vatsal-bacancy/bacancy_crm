class Clients::ShipmentsMailer < ApplicationMailer
  helper ApplicationHelper

  def build_email(shipment)
    @shipment = shipment
    mail(to: @shipment.email_recipients, subject: 'iPos Shipping Confirmation')
  end
end
