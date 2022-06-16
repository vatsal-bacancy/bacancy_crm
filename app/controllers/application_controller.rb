class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_by_resource
  #rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  after_action :clear_xhr_flash
  # before_action :find_client_list, :select_client
  before_action :select_company
  before_action :set_action

  before_action :set_time_machine_user # Time machine current_user hook

  #prepend_before_action :sign_out_existing_user
  def checked_permission?(permissions, klass, action)
    return true if current_user.has_role?(:super_admin)
    permissions.include?({"klass_id"=> klass.id, "action_id"=> action.id})
  end


  # def checked_permission?(user, permissions, klass, action)
  #   return true if user.has_role?(:super_admin)
  #   permissions.include?({"klass_id"=> klass.id, "action_id"=> action.id})
  # end

  def can_perform?(klass, action)
    if current_user.user_permission.permissions.include?({"klass_id"=> klass.id, "action_id"=> action.id})
      return
    else
      redirect_to root_path, notice: "You don't have permission to #{action.name} this."
    end
  end

  def create_document(object, document_ids, attachments, resourcable)
    if document_ids.present?
      document_ids.split(",").map {|i| i.to_i}.uniq.each do |doc_id|
        object.document_documentables.create(document_id: doc_id,resourcable: resourcable)
      end
    end
    # if attachments.present?
    #   attachments.each do |attachment|
    #     directory = @company.directories.where(name: 'system').first
    #     document = Document.create(resourcable: current_user, attachment: attachment)
    #     document.document_documentables.create(documentable: directory)
    #     object.document_documentables.create(document: document)
    #   end
    # end
  end

  # todo: remove this patch
  def multi_select_params_permit(klass)
    names = klass.fields.where(column_type: 'Multi-Select Check Box').pluck(:name)
    klass_name = klass.name.downcase
    # adds empty array if not passed in params
    names.each do |name|
      (params[klass_name][name] = params[klass_name][name] || []) if params[klass_name] && params[klass_name][name]
    end
    names.collect{|m| {m=> []}}
  end

  private

  def set_action
    @action_delete = Action.find_by_name('delete')
    @action_update = Action.find_by_name('update')
    @action_create = Action.find_by_name('create')
    @action_read = Action.find_by_name('read')
    @action_list =  Action.pluck(:name,:id).to_h
    @klass_list = Klass.pluck(:name, :id).to_h
  end

  def select_company
    @company = Company.first
    @system_directory = @company.directories.where(name: 'system').first
  end

  def clear_xhr_flash
    if request.xhr?
      # Also modify 'flash' to other attributes which you use in your common/flashes for js
      flash.discard
    end
  end

  def layout_by_resource
    if devise_controller?
      "registration"
    else
      "application"
    end
  end

  def handle_record_not_found
    flash[:notice] = "Record not found"
    redirect_to root_path
  end

  def select_client
    if current_user
      session[:client_id] = Client.unscoped.where(is_admin: true).first.id if  current_user.has_role? (:super_admin)
      clients = current_user.clients
      if session[:client_id].nil? &&  params[:controller] != 'users/sessions' && clients.count > 1
        redirect_to  select_client_clients_path
      elsif clients.count == 1
        session[:client_id] = current_user.clients.first.id
      end
    end
  end

  def find_client_list

    @client_list = []
    return if current_user && current_user.has_role?(:super_admin)
    if current_user.present?
      @client_list = current_user.clients
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :user
      new_user_session_path
    elsif resource_or_scope == :contact
      new_contact_session_path
    end
  end

end
