class InvoicePdf < ApplicationRecord
  belongs_to :invoice
  # has_one :document, as: :documentable, dependent: :destroy
  has_one :document_documentable, as: :documentable, dependent: :destroy
  has_one :document, through: :document_documentable
end
