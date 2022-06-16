# Future replacement for file uploading
# replaces: (DocumentDocumentable, Document, Directory, etc..)

module FileManager
  def self.table_name_prefix
    'file_manager_'
  end
end
