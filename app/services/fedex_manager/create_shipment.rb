# TODO: Currently We only supports sender paid, we can dynamically determine payment type using `payment_type` method
#
class FedexManager::CreateShipment < FedexManager::Base
  attr_reader :shipper, :recipient, :packages, :shipping_options, :total_package_weight, :total_package_count, :service_type, :payment_type

  def initialize(shipper_person_name:, shipper_person_phone_no:, shipper_street_line:, shipper_city:, shipper_state:, shipper_country:, shipper_zip_code:,
    recipient_person_name:, recipient_person_phone_no:, recipient_street_line:, recipient_city:, recipient_state:, recipient_country:, recipient_zip_code:,
    ship_date:, service_type:, package_type:, payment_type:, drop_off_type:, weights:)
    @shipper   = build_address(shipper_person_name, shipper_person_phone_no, shipper_street_line, shipper_city, shipper_state, shipper_country, shipper_zip_code, 'false')
    @recipient = build_address(recipient_person_name, recipient_person_phone_no, recipient_street_line, recipient_city, recipient_state, recipient_country, recipient_zip_code, 'false')

    @packages = build_packages(weights)
    @shipping_options = build_shipping_options(package_type, drop_off_type, ship_date)
    @total_package_weight, @total_package_count = build_total_package(weights)

    @service_type = service_type
    @payment_type = payment_type
  end

  def validate
    errors = []
    begin
      packages.each do |package|
        fedex.validate_shipment(
          shipper: shipper,
          recipient: recipient,
          packages: [ package ],
          service_type: service_type,
          shipping_options: shipping_options
        )
      end
    rescue Fedex::RateError => e
      errors.push(e.message)
    end
    return errors
  end

  def ship!
    responses = []
    master_label = nil
    packages.each.with_index(1) do |package, index|
      response = if index == 1 # For master package label
                   master_label = fedex.label(
                     shipper: shipper,
                     recipient: recipient,
                     packages: [ package ],
                     service_type: service_type,
                     shipping_options: shipping_options,
                     mps: { package_count: total_package_count, total_weight: total_package_weight, sequence_number: index.to_s }
                   )
                 else
                   fedex.label(
                     shipper: shipper,
                     recipient: recipient,
                     packages: [ package ],
                     service_type: service_type,
                     shipping_options: shipping_options,
                     mps: {
                       master_tracking_id: { tracking_number: master_label.tracking_number },
                       package_count: total_package_count, total_weight: total_package_weight, sequence_number: index.to_s
                     }
                   )
                 end
      responses.push(response)
    end
    tracking_numbers = responses.map(&:tracking_number)
    yield tracking_numbers, responses
  end

  private

  def build_address(person_name, person_phone_no, street_line, city, state, country, zip_code, residential)
    {
      name: person_name,
      phone_number: person_phone_no,
      address: street_line,
      city: city,
      state: state,
      postal_code: zip_code,
      country_code: country,
      residential: residential
    }
  end

  def build_packages(weights)
    weights.map do |weight|
      { weight: { units: 'LB', value: weight } }
    end
  end

  def build_shipping_options(package_type, drop_off_type, ship_date)
    {
      packaging_type: package_type,
      drop_off_type: drop_off_type,
      ship_timestamp: ship_date.iso8601
    }
  end

  def build_total_package(weights)
    [{ value: weights.sum, units: 'LB' }, weights.size]
  end
end
