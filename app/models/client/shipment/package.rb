class Client::Shipment::Package < ApplicationRecord
  default_scope -> { order(id: :asc) }

  scope :select_except_response, -> { select(column_names - ['raw_response']) }

  belongs_to :shipment

  def response=(raw)
    self.raw_response = Marshal.dump(raw)
  end

  def response
    @response ||= Marshal.load(self.raw_response)
  end

  def label
    response.image
  end

  def shipped?
    tracking_number.present?
  end

  def carrier
    'FedEx'
  end

  def quantity
    1
  end

  def tracking_status
    'Shipped'
  end

  def tracking_url
    "https://www.fedex.com/apps/fedextrack/index.html?tracknumbers=#{tracking_number}"
  end
end
