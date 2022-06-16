class DirectoriesController < ApplicationController

  def new
    @directory = Directory.new(directoriable_type: params[:directoriable_type], directoriable_id: params[:directoriable_id])
  end


  def create
    @directory = Directory.new(directory_params.merge({ resourcable: current_user || current_contact}))
    if @directory.save
      flash[:success] = "Directory successfully added"
    else
      flash[:danger] = @directory.errors.full_messages.join(",")
    end
  end

  def show
    if params[:dir_id].present?
      @directory = Directory.find(params[:dir_id]).directoriable
    elsif params[:id].present?
      @directory = Directory.find(params[:id])
    end
  end

  def destroy
    @directory = Directory.find(params[:id])
    @object = @directory.directoriable

    if params[:directory_id]
      @dir = @directory.document_documentables
      @dir.each do |doc|
        @document = Document.find(doc.document_id)
        @document.destroy
        doc.destroy
      end
      if @directory.destroy
        flash[:success] = "Permanant delete"
      else
        flash[:danger] = "Not delete"
      end

      @directory = Directory.find(params[:directory_id])
    else
      @dir =  @directory.document_documentables
      @dir.each do |doc|
        @document = doc.document
        @document.destroy
      end
      if @directory.destroy
        flash[:success] = "Directory Successfully deleted"
      else
        flash[:danger] = @directory.errors.full_messages.join(",")
      end
      @directory = @company.directories.where(name: nil).first
    end

    #@directory = @company.directory
    @directories = @directory.directories
    @documents = @directory.documents
  end

  def edit
    @directory = Directory.find(params[:id])
  end

  def update
    @directory = Directory.find(params[:id])
    @directory.update_attributes(directory_params)
  end

  def index
    if params[:directory_id].present?
      @directory =Directory.find(params[:directory_id])
    else
      @directory = @company.directories.where(name: nil).first
    end
    @directories = @directory.directories
    @documents = @directory.documents
  end

  def system_files
    @directory = @company.directories.where(name: 'system').first
    @documents = @directory.documents
  end

  def destroy_all
    @all_directories = Directory.where(id: params[:ids])
    @directory =  @all_directories.first.directoriable
    @directories = @directory.directories
    @documents = @directory.documents
    @all_directories.destroy_all
  end

  private

  def directory_params
      params.require(:directory).permit(:name, :directoriable_type, :directoriable_id)
  end
end
