class EmailTemplete < ApplicationRecord
  belongs_to :user
  belongs_to :template_dir, optional: true

  # has_many :documents, as: :documentable, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables
end
