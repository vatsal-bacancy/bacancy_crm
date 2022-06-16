class ClientTaskLog < ApplicationRecord
  belongs_to :user
  belongs_to :client

  def self.checkin_checkout(_user, client)
    ctl = client.client_task_logs.first
    [!ctl&.user_checkin_timestamp.blank?, !ctl&.user_checkout_timestamp.blank?]
  end
end
