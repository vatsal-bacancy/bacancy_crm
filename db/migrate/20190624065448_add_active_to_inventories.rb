class AddActiveToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :active, :boolean, default: true
  end
end
