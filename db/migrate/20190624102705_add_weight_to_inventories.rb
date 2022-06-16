class AddWeightToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :weight, :float
  end
end
