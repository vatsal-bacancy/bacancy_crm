class TicketContact < ApplicationRecord
  belongs_to :contact
  belongs_to :ticket
  after_create :create_unread

  def create_unread
    Unread.create(unreadable: ticket, resourcable: contact)
  end
end
