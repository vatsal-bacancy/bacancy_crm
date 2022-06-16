class FileManager::FilesController < ApplicationController
  before_action :authenticate_user!

  def bulk_create
    file_ids = []
    attachments.each do |attachment|
      file_ids.push(FileManager::File.create(attachment: attachment, folder: FileManager::Folder.system_folder, owner: current_user).id)
    end
    render json: { file_ids: file_ids }
  end

  def selected_files
    @files = FileManager::File.find(params[:file_ids])
  end

  private

  def attachments
    params[:attachments] || []
  end
end
