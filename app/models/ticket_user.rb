class TicketUser < ApplicationRecord
  belongs_to :user
  belongs_to :ticket

  after_create :create_unread

  def create_unread
    Unread.create(unreadable: ticket, resourcable: user)
  end
end
