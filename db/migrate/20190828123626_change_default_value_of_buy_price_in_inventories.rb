class ChangeDefaultValueOfBuyPriceInInventories < ActiveRecord::Migration[5.1]
  def change
    change_column_default :inventories, :buy_price, from: 0.0, to: nil
  end
end
