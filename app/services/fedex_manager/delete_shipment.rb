class FedexManager::DeleteShipment < FedexManager::Base
  attr_reader :tracking_number

  def initialize(tracking_number)
    @tracking_number = tracking_number
  end

  def delete!
    fedex.delete(tracking_number: tracking_number)
  end
end
