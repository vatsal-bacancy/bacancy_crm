class FedexManager::TrackShipment < FedexManager::Base
  attr_reader :tracking_number

  def initialize(tracking_number)
    @tracking_number = tracking_number
  end

  def track!
    fedex.track(tracking_number: tracking_number)
  end
end
