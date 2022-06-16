class Directory < ApplicationRecord
  # acts_as_paranoid
  audited
  default_scope { order(:name) }

  belongs_to :directoriable, polymorphic: true, optional: true
  # belongs_to :user, optional: true
  belongs_to :resourcable, polymorphic: true, optional: true
  # has_many :documents, dependent: :destroy
  has_many :directories, as: :directoriable, dependent: :destroy
  has_many :document_documentables, as: :documentable, dependent: :destroy
  has_many :documents, through: :document_documentables
  # accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true
  # accepts_nested_attributes_for :directories, reject_if: :all_blank, allow_destroy: true

  def get_directory
    Directory.find(self.directoriable_id).id
  end

  def directory_on_index(id)
    Directory.find(id).name
  end

end
