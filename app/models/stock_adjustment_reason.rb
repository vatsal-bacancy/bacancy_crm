class StockAdjustmentReason < ApplicationRecord
  scope :all_active, -> {where(active: true)}

  has_many :stock_adjustments, dependent: :destroy
end
