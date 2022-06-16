# FileManager::File attributes:
# attachment (for Carrierwave)
# folder
# owner (polymorphic: User/Contact)


class FileManager::File < ApplicationRecord
  mount_uploader :attachment, FileManager::FileUploader

  belongs_to :owner, polymorphic: true
  belongs_to :folder, class_name: 'FileManager::Folder'

  has_many :file_associations, class_name: 'FileManager::FileAssociation', dependent: :destroy
end
