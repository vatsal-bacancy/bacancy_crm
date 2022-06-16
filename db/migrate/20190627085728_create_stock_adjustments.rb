class CreateStockAdjustments < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_adjustments do |t|
      t.references :stock_adjustment_reason, foreign_key: true
      t.references :inventory, foreign_key: true
      t.date :date
      t.integer :adjustment_type, default: 0
      t.string :reference_no
      t.integer :new_quantity_on_hand
      t.integer :quantity_adjusted
      t.float :new_value, default: 0.0
      t.float :value_adjusted, default: 0.0
      t.string :description

      t.timestamps
    end
  end
end
