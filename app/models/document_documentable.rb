class DocumentDocumentable < ApplicationRecord
  belongs_to :document
  belongs_to :documentable, polymorphic: true
  belongs_to :resourcable, polymorphic: true, optional: true
end
