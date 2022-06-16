class AddTicketableToTickets < ActiveRecord::Migration[5.1]
  def change
    add_reference :tickets, :ticketable, polymorphic: true
  end
end
