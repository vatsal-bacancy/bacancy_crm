class AddImageToInventoryGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_groups, :image, :string
  end
end
