# TODO: FIXME: user_id is not treated as a foreign key
class Note < ApplicationRecord
  audited

  scope :ordered, -> { order(created_at: :desc) }

  belongs_to :user
  belongs_to :noteable, polymorphic: true

  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables

  def field_data
    field_name = Field.where(klass_id: Klass.find_by(name: "Note"))
    field_name.each do |name|
      if name.name == "content"
        return true
      end
    end
  end
end
