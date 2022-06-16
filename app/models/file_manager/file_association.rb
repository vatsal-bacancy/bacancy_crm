# FileManager::FileAssociation attributes:
# title
# associable (polymorphic: Lead/Client/ etc...)
# field
# file

class FileManager::FileAssociation < ApplicationRecord
  belongs_to :associable, polymorphic: true
  belongs_to :field
  belongs_to :file, class_name: 'FileManager::File'
end
