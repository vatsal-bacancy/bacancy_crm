class Cemail < ApplicationRecord
  #belongs_to :email_templete
  belongs_to :cemailable, polymorphic: true
  # has_many :documents, as: :documentable, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables
  
end
