class InvoiceInventory < ApplicationRecord
  belongs_to :invoice
  belongs_to :inventory

  has_one :stock_adjustment, dependent: :destroy

  after_save :update_stock_adjustments

  before_validation :reload_inventory
  validate :validate_quantity

  def rate
    sprintf '%.2f', super
  end

  def tax
    sprintf '%.2f', super
  end

  def amount
    sprintf '%.2f', super
  end

  def amount_with_tax
    sprintf '%.2f', amount_without_formatting + amount_without_formatting * tax_without_formatting / 100
  end

  def rate_without_formatting
    read_attribute(:rate)
  end

  def tax_without_formatting
    read_attribute(:tax)
  end

  def amount_without_formatting
    read_attribute(:amount)
  end

  def amount_with_tax_without_formatting
    amount_without_formatting + amount_without_formatting * tax_without_formatting / 100
  end

  private

  def reload_inventory
    inventory.reload # inventory not reloaded between multiple inventories
  end

  def update_stock_adjustments
    stock_adjustment_reason = StockAdjustmentReason.find_by(reason: 'Invoice generated')
    StockAdjustment.find_or_create_by(invoice_inventory_id: self.id).update(stock_adjustment_reason: stock_adjustment_reason, inventory: inventory, date: Date.today, adjustment_type: 'Quantity', new_quantity_on_hand: inventory.available_quantity - qty, quantity_adjusted: -qty, description: '')
  end

  def validate_quantity
    self.errors.add(:base, "You don't have enough stock") if inventory.available_quantity - qty < 0
  end
end
