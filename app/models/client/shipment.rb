class Client::Shipment < ApplicationRecord
  default_scope { order(created_at: :desc) }

  belongs_to :client

  has_many :packages, dependent: :destroy

  accepts_nested_attributes_for :packages, allow_destroy: true

  before_create :validate_shipment
  after_create  :schedule_shipment

  PERMITTED_PARAMS = [
    :shipper_person_name, :shipper_person_phone_no, :shipper_street_line, :shipper_city, :shipper_state, :shipper_country, :shipper_zip_code,
    :recipient_person_name, :recipient_person_phone_no, :recipient_street_line, :recipient_city, :recipient_state, :recipient_country, :recipient_zip_code,
    :ship_date, :service_type, :package_type, :payment_type, :drop_off_type,
    packages_attributes: [:id, :_destroy, :description, :weight]
  ]

  def validate_shipment
    errors = build_fedex_create_shipment.validate
    self.errors[:base].concat(errors)
    raise ActiveRecord::Rollback if errors.present?
  end

  def schedule_shipment
    Clients::ShipmentsWorker.perform_async(:ship!, id)
  end

  def ship!
    build_fedex_create_shipment.ship! do |tracking_numbers, responses|
      packages.each_with_index do |package, index|
        package.tracking_number = tracking_numbers[index]
        package.response        = responses[index]
      end
    end
    self.save!
    Clients::ShipmentsMailer.build_email(self).deliver
  end

  def recipient_address
    [recipient_street_line, recipient_city, recipient_state, recipient_country, recipient_zip_code].join(', ')
  end

  def shipped?
    packages.select_except_response.map(&:shipped?).all?
  end

  def email_recipients
    (self.client.contacts.pluck(:email) + [self.client.company_email, self.client.user.email]).compact.uniq
  end

  def module_number
    "SHIP0#{self.id}"
  end

  def client_merchant_id
    client.merchant_id
  end

  def client_company_name
    client.company_name
  end

  # Note: `supported_*_types` is only used in view for rendering
  def self.supported_service_types
    @supported_service_types ||= FedexManager::Base.supported_service_types.map{ |type| [type.titleize, type] }
  end

  def self.supported_package_types
    @supported_package_types ||= FedexManager::Base.supported_package_types.map{ |type| [type.titleize, type] }
  end

  def self.supported_payment_types
    @supported_payment_types ||= FedexManager::Base.supported_payment_types.map{ |type| [type.titleize, type] }
  end

  def self.supported_drop_off_types
    @supported_drop_off_types ||= FedexManager::Base.supported_drop_off_types.map{ |type| [type.titleize, type] }
  end

  private

  def packages_weights
    self.packages.map(&:weight)
  end

  def build_fedex_create_shipment
    FedexManager::CreateShipment.new(
      shipper_person_name: shipper_person_name,
      shipper_person_phone_no: shipper_person_phone_no,
      shipper_street_line: shipper_street_line,
      shipper_city: shipper_city,
      shipper_state: shipper_state,
      shipper_country: shipper_country,
      shipper_zip_code: shipper_zip_code,
      recipient_person_name: recipient_person_name,
      recipient_person_phone_no: recipient_person_phone_no,
      recipient_street_line: recipient_street_line,
      recipient_city: recipient_city,
      recipient_state: recipient_state,
      recipient_country: recipient_country,
      recipient_zip_code: recipient_zip_code,
      ship_date: ship_date,
      service_type: service_type,
      package_type: package_type,
      payment_type: payment_type,
      drop_off_type: drop_off_type,
      weights: packages_weights)
  end
end
