class RemoveAssignedToFromTickets < ActiveRecord::Migration[5.2]
  def change
    remove_reference :tickets, :assigned_to, foreign_key: { to_table: :users }
  end
end
