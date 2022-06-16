class AddUserAssignedAtToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :user_assigned_at, :datetime
  end
end
