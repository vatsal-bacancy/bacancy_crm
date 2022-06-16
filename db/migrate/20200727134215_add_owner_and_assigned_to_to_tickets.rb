class AddOwnerAndAssignedToToTickets < ActiveRecord::Migration[5.2]
  def change
    add_reference :tickets, :owner, foreign_key: { to_table: :users }
    add_reference :tickets, :assigned_to, foreign_key: { to_table: :users }
  end
end
