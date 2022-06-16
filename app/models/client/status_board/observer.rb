# This observer used for observing the fields changes if `Client.lead_status` set to `CLIENT_STATUS_CHANGED_TO`
#   See Client::StatusBoard::Base for more

module Client::StatusBoard::Observer
  extend ActiveSupport::Concern

  CLIENT_STATUS_CHANGED_TO = 'Production Mode'

  included do
    before_save do
      if self.lead_status == CLIENT_STATUS_CHANGED_TO
        (self.status_board ||= self.build_status_board).update_observable_fields
      end
    end
  end
end
