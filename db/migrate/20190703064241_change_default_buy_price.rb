class ChangeDefaultBuyPrice < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:inventories, :buy_price, 0.0)
    Inventory.where(buy_price: nil).update_all(buy_price: 0.0)
  end
end
