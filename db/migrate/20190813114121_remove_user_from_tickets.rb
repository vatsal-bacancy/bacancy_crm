class RemoveUserFromTickets < ActiveRecord::Migration[5.1]
  def change
    remove_reference :tickets, :user
  end
end
