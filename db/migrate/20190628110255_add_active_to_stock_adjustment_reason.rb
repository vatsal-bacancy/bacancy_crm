class AddActiveToStockAdjustmentReason < ActiveRecord::Migration[5.1]
  def change
    add_column :stock_adjustment_reasons, :active, :boolean, default: true
  end
end
