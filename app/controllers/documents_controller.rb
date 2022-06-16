class DocumentsController < ApplicationController

  def index
    @directories = Directory.all
    @documents = Document.where(directory_id: nil)
  end

  def upload_document
    if params[:directory_id].present?
      @directory = Directory.find(params[:directory_id])
    else
      @directory = @company.directories.where(name: nil).first
    end
  end

  def update_documents
    @directory = Directory.find(params[:directory_id])
  end

  def new
    @document = Document.new()
    @documentable_type = params[:documentable_type]
    @documentable_id = params[:documentable_id]

    @users = User.all.active
  end

  def create
    # Document.upload_documents(document_params, attachment_paths)
    if params[:documentable_type] == "Lead"
      @object = Lead.find(params[:documentable_id])
    elsif params[:documentable_type] == "Client"
      @object = Client.find(params[:documentable_id])
    end
    create_document(@object, params[:document_ids], params[:attachments],current_user)

    # params[:document_ids].split(",").map {|i| i.to_i}.uniq.each do |doc_id|
    #   @object.document_documentables.create(document_id: doc_id)
    # end
  end

  def show
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    data = @document.attachment.rename(params[:document][:attachment])
    data.save
    # attachment_file_name
    #@document.save
    @directory = @company.directories.where(name: nil).first
  end

  def destroy
    @document = Document.find(params[:id])
    @documentable_data = @document.document_documentables
    if params[:documentable_type] == "Lead" || params[:documentable_type] =="Client"
      @object = params[:documentable_type].constantize.find(params[:documentable_id])
      @doc = DocumentDocumentable.where(documentable: @object).where(document: @document).first
      @doc.destroy
    elsif params[:object_type].present? || params[:file_remove].present?
      object = params[:object_type].constantize.find(params[:object_id])
      documentable = DocumentDocumentable.find_by(documentable: object, document_id: params[:id])
      if documentable.destroy
        flash[:success] = "Document deleted successfully"
      else
        flash[:danger] = document.errors.full_messages.join(",s")
      end
    else
      if @document.destroy
        flash[:success] = "Document deleted successfully"
      else
        flash[:danger] = @document.errors.full_messages.join(",s")
      end
    end

    if params[:directory_id].present?
      @directory = Directory.find(params[:directory_id])
      #@doc = @documentable_data.find_by(documentable_type: @directory.class.name, documentable_id: @directory.id)
    else
      #@doc = @documentable_data.find_by(documentable_type: params[:documentable_type], documentable_id: params[:documentable_id])
      @directory = @company.directories.where(name: nil).first
    end

    # # tempary delete
    # if @doc.documentable_type == "Directory"
    #   if @document.destroy
    #     flash[:success] = "Permenant Destroy successfully"
    #   else
    #     flash[:danger] = "Enable to delete"
    #   end
    # else
    #   if @doc.destroy
    #     flash[:success] = "Destroy successfully"
    #   else
    #     flash[:danger] = "Enable to delete"
    #   end
    # end
    # if params[:documentable_type] == "Lead" || params[:documentable_type] =="Client"
    #   @object = params[:documentable_type].constantize.find(params[:documentable_id])
    # end
    @directories = @directory.directories
    @documents = @directory.documents
  end

  def destroy_all
    @documents = DocumentDocumentable.where(document_id: params[:ids])
    @directory =  @documents.where(documentable_type: "Directory").first.documentable
    @directories = @directory.directories

    # delete document of lead and client
    if params[:documentable_type] == "Lead" || params[:documentable_type] =="Client"
      @object = params[:documentable_type].constantize.find(params[:documentable_id])
      @doc = DocumentDocumentable.where(document_id: params[:ids]).where(documentable: @object)
      @doc.destroy_all
    else
      #delete from file drive
      @documents.destroy_all
    end
    #@documents.destroy_all
    # @directory =  @documents.where(documentable_type: "Directory").first.documentable
    # @directories = @directory.directories
    @documents = @directory.documents
  end

  def upload
    valid_params = params[:document] ? document_params : document_local_params
    @document = Document.new(valid_params)
    @document.save
    d_id = { d_id: @document.id }
    d = @document.document_documentables.create(documentable_type: params[:documentable_type], documentable_id: params[:documentable_id], resourcable: current_user)
    respond_to do |format|
      format.json{ render json: d_id }
    end
  end

  def selected_documents
    @documents = Document.where(id: params[:document_ids])
  end

  private

  def document_params
    params.require(:document).permit(:documentable_type, :documentable_id, :resourcable_id, :resourcable_type, :title, :attachment)
  end

  def document_local_params
    params.permit(:resourcable_id, :resourcable_type, :title, :attachment)
  end

  def attachment_paths
    if  params[:document] && params[:document][:attachment]
      params[:document][:attachment].collect{|a| [a.tempfile.path, a.original_filename]}
    else
      []
    end
  end
end
