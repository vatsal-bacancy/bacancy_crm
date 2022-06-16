class InvoiceTax < ApplicationRecord
  #has_many :invoice_inventories, dependent: :destroy

  def tax_amount
    sprintf '%.2f', self.tax_rate
  end
end
