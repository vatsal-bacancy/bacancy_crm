class FileManager::FileAssociationsController < ApplicationController
  before_action :authenticate_user!

  def bulk_new
    @file_association = FileManager::FileAssociation.new(associable: associable)
  end

  def bulk_create
    params[:file_ids].split(',').each do |file_id|
      FileManager::FileAssociation.create(title: params[:title], associable: associable, field_id: params[:field_id], file_id: file_id)
    end
  end

  def edit
    file_association
  end

  def update
    file_association.update(title: params[:title], field_id: params[:field_id], file_id: params[:file_ids].split(',')[0])
    associable
  end
  
  def destroy
    file_association.destroy
  end

  private

  def associable
    @associable ||= begin
                      associable = params[:associable].split(':')
                      associable[0].constantize.find(associable[1])
                    end
  end

  def file_association
    @file_association ||= if params[:id].present?
                            FileManager::FileAssociation.find(params[:id])
                          else
                            FileManager::FileAssociation.new(associable: associable)
                          end
  end
end
