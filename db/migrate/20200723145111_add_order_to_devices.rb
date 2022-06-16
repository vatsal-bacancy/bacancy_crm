class AddOrderToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :order, :integer
  end
end
