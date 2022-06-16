class Clients::ShipmentsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0 # Do not retry if shipment fails

  def perform(method_name, args = nil)
    send(method_name, args)
  end

  def ship!(id)
    Client::Shipment.find(id).ship!
  end
end
