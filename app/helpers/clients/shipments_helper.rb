module Clients::ShipmentsHelper

  def shipment_package_label_links(client, shipment)
    return 'Shipping..' unless shipment.shipped?
    shipment.packages.select_except_response.map do |package|
      link_to(package.tracking_number, client_shipment_package_label_path(client, shipment, package), target: :_blank, class: 'common-link')
    end.join(', ').html_safe
  end
end
