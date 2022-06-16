class ProjectDocumentsController < ApplicationController

  def index
    @project = Project.find(params[:project_id])
    #@documents = @project.messages.group_by{|t| t.created_at.to_date }
    @overviews = (@project.messages + @project.document_documentables + @project.messages.map{ |msg| msg.document_documentables}).flatten.sort{|a,b| b.created_at <=> a.created_at }.group_by{|t| t.created_at.to_date }
  end

  def new
    @project = Project.find(params[:project_id])

    @documents = @project.project_documents
    @document = @project.project_documents.build
  end

  def create
    @project = Project.find(params[:project_id])
    params[:project_document][:attachment].each do |attachment|
      @document =@project.project_documents.build(attachment: attachment, user_id: current_user.id)
      @document.save
    end
    @documents = @project.project_documents.reorder(created_at: :desc)
  end

  def destroy
    if params[:klass_name] == "Project"
      @project_ticket = Project.find(params[:project_id])
    elsif params[:klass_name] == "Ticket"
      @project_ticket = Ticket.find(params[:project_id])
    end
    @document = DocumentDocumentable.where(documentable: Message.find(params[:message_id])).where(document_id: params[:id]).first
    #@document = ProjectDocument.find(params[:id])
    #@project = @document.documentable.messageable
    @document.destroy
    @documents = @project_ticket.messages.group_by{|t| t.created_at.to_date }
    #@documents = @project.document_documentables.group_by{|t| t.created_at.to_date }
  end
end
