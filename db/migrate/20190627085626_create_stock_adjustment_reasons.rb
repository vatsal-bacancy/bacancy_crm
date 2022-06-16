class CreateStockAdjustmentReasons < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_adjustment_reasons do |t|
      t.string :reason

      t.timestamps
    end
  end
end
