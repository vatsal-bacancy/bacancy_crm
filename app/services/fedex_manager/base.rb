class FedexManager::Base

  def self.supported_service_types
    Fedex::Request::Base::SERVICE_TYPES
  end

  def self.supported_package_types
    Fedex::Request::Base::PACKAGING_TYPES
  end

  # Note: Currently we only support sender payment
  def self.supported_payment_types
    ['SENDER']
  end

  def self.supported_drop_off_types
    Fedex::Request::Base::DROP_OFF_TYPES
  end

  private

  def fedex
    @fedex ||= Fedex::Shipment.new(credentials)
  end

  def credentials
    @@credentials ||= {
      key: ENV.fetch('FEDEX_AUTH_KEY'),
      password: ENV.fetch('FEDEX_SECURITY_CODE'),
      account_number: ENV.fetch('FEDEX_ACCOUNT_NUMBER'),
      meter: ENV.fetch('FEDEX_METER_NUMBER'),
      mode: Rails.env
    }
  end
end
