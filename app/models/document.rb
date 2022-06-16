class Document < ApplicationRecord
  #acts_as_paranoid
  audited
  # belongs_to :directory, optional: true
  # belongs_to :user
  belongs_to :resourcable, polymorphic: true, optional: true

  # belongs_to :documentable, polymorphic: true
  mount_uploader :attachment, DocumentUploader
  has_many :document_documentables, dependent: :destroy

  def title_to_dipslay
    (title.present? ? title : (attachment.file.filename rescue '')).truncate(25)
  end

  def self.upload_documents(document_params, attachments)
     attachments.each do |attachment|
      document = Document.new(document_params.merge({attachment: File.open(attachment[0])}))
      document.attachment.filename = attachment[1]
      document.save
      File.delete(attachment[0]) if File.exist?(attachment[0])
    end
  end

  def get_directory
    Directory.find(self.document_documentables[0].documentable_id).id
  end
end
