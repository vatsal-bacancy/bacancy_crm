class Clients::ShipmentsController < ApplicationController
  before_action :authenticate_user!

  def new
    company = @company
    shipment.assign_attributes(
      shipper_person_name: company.user.fullname, shipper_person_phone_no: nil,
      shipper_street_line: company.street_address, shipper_city: company.city,
      shipper_state: company.state, shipper_country: 'US', shipper_zip_code: company.zip_code,
      recipient_person_name: nil, recipient_person_phone_no: nil,
      recipient_street_line: client.street_address, recipient_city: client.city,
      recipient_state: client.state, recipient_country: 'US', recipient_zip_code: client.zip_code
    )
    shipment.packages.build
  end

  def create
    if shipment.update(shipment_params)
      flash[:success] = 'Shipment Successfully Created!'
    else
      flash[:danger] = shipment.errors.full_messages.to_sentence
    end
  end

  def package_label
    package = client.shipments.find(params[:shipment_id]).packages.find(params[:id])
    send_data(package.label, filename: "#{package.tracking_number}.pdf")
  end

  private

  def shipment
    @shipment ||= if params[:id].present?
                    client.shipments.find(params[:id])
                  else
                    client.shipments.new
                  end
  end

  def client
    @client ||= Client.find(params[:client_id])
  end

  def shipment_params
    params.require(:client_shipment).permit(Client::Shipment::PERMITTED_PARAMS)
  end
end
