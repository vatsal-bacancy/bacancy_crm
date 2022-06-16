class AddStatusToInventories < ActiveRecord::Migration[5.2]
  def change
    add_column :inventories, :status, :string
  end
end
