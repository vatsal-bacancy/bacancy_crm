# FileManager::Folder attributes:
# name
# owner (polymorphic: User/Contact)

class FileManager::Folder < ApplicationRecord
  # TODO: has_ancestry

  belongs_to :owner, polymorphic: true

  has_many :files, class_name: 'FileManager::File', dependent: :destroy

  def self.system_folder
    FileManager::Folder.find_by(name: 'System')
  end
end
