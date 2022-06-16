class Contacts::ProjectDocumentsController < ApplicationController

  def index
    @project = Project.find(params[:project_id])
    @documents = @project.messages.group_by{|t| t.created_at.to_date }
    @overviews = (@project.messages + @project.documents).sort{|a,b| a.created_at <=> b.created_at }.group_by{|t| t.created_at.to_date }
  end

  def new
    @project = Project.find(params[:project_id])

    @documents = @project.project_documents
    @document = @project.project_documents.build
  end

  def create
    @project = Project.find(params[:project_id])
    params[:project_document][:attachment].each do |attachment|
      @document =@project.project_documents.build(attachment: attachment, resourcable: current_client)
      @document.save
    end
    @documents = @project.project_documents.reorder(created_at: :desc)
  end

  def destroy
    @object = params[:object_type].constantize.find(params[:object_id])
    @document = DocumentDocumentable.find_by(document_id: params[:id], documentable: @object)
    @document.destroy
  end
end
