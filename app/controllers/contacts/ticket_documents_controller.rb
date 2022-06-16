class Contacts::TicketDocumentsController < ApplicationController
  def index
    @ticket = Ticket.find(params[:ticket_id])
    @documents = @ticket.messages.group_by{|t| t.created_at.to_date }
    @overviews = (@ticket.messages + @ticket.documents).sort{|a,b| a.created_at <=> b.created_at }.group_by{|t| t.created_at.to_date }
  end

  def new
    @ticket = Ticket.find(params[:ticket_id])

    @documents = @ticket.project_documents
    @document = @ticket.project_documents.build
  end

  def create
    @ticket = Ticket.find(params[:ticket_id])
    params[:ticket_document][:attachment].each do |attachment|
      @document =@project.ticket_documents.build(attachment: attachment, user_id: current_user.id)
      @document.save
    end
    @documents = @ticket.ticket_documents.reorder(created_at: :desc)
  end

  def destroy
    @object = params[:object_type].constantize.find(params[:object_id])
    @document = DocumentDocumentable.find_by(document_id: params[:id], documentable: @object)
    @document.destroy
    @documents = @object.document_documentables.group_by{|t| t.created_at.to_date }

  end
end
