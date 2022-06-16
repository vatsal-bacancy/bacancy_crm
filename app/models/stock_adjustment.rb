class StockAdjustment < ApplicationRecord
  belongs_to :stock_adjustment_reason
  belongs_to :inventory
  belongs_to :invoice_inventory, optional: true

  enum adjustment_type: %w[Quantity Value]
  PERMITTED_PARAMS = %i[id stock_adjustment_reason_id inventory_id date adjustment_type reference_no new_quantity_on_hand quantity_adjusted new_value value_adjusted description current_value current_quantity]

  after_save :update_inventory_stock
  after_destroy :update_inventory_stock

  def reason_label
    stock_adjustment_reason.reason
  end

  def adjustment_label
    adjustment_type == 'Quantity' ? "#{quantity_adjusted} #{inventory.unit_label}" : "$#{value_adjusted}"
  end

  private

  def update_inventory_stock
    inventory.recalculate_current_stock
  end
end
