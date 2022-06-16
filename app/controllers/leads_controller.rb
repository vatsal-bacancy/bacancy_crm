class LeadsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    @users = User.all
    @lead = Lead.new
    @klass = Klass.find_by(name: "Lead")
    @lead.contacts.build
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def edit
    @users = User.all
    @lead = Lead.find(params[:id])
    @klass = Klass.find_by(name: "Lead")
    @groups = Group.includes(:fields).where(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def edit_summary
    @lead = Lead.find(params[:id])
    @group = Group.find(params[:group_id])
    @klass = Klass.find_by(name: "Lead")
    user_details = User.all.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def index
    @klass = Klass.find_by(name: "Lead")
    can_perform?(@klass, @action_read)
    @leads = Lead.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @data = {user_id: User.all.pluck(:first_name, :id)}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    respond_to do |format|
      format.js
      format.html
      format.csv { send_data @leads.to_csv, filename: "leads-#{Date.today}.csv" }
      format.json do
        render json: LeadDatatable.new(params, objects: @leads, fields: @fields, fields_picklist_data: @data)
      end
    end
  end

  def show
    @users = User.all
    @lead = Lead.find(params[:id])
    @klass = Klass.find_by(name: "Lead")
    @task_klass = Klass.find_by(name: "Task")
    @task_fields = current_user.fields_for_table_with_order(klass: @task_klass)
    @ticket_klass = Klass.find_by(name: "Ticket")
    @ticket_fields = current_user.fields_for_table_with_order(klass: @ticket_klass)
    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
    @groups = Group.includes(:fields).where(klass: @klass)
    @notes = @lead.notes
    @note =  Note.new
    # @lead.fields.build lead picklist
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    #ticket picklist value
    @ticket_data = {}
    fields = Field.where(klass: @ticket_klass, have_custom_value: true)
    fields.each do |field|
      @ticket_data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def create
    @lead = Lead.new(lead_params)
    @klass = Klass.find_by(name: "Lead")
    if @lead.save
      module_number = @klass.module_number
      @lead.update_attributes(lead_no: "#{module_number.module_prefix} #{module_number.sequence_start.to_i+@lead.id-1}")
      flash[:success] = 'Lead Successfully Added!'
      if client_contacts_params["contacts_attributes"]
        client_contacts_params["contacts_attributes"].each do |contact, data|
          data.delete("_destroy")
          @contact = Contact.find_or_create_by(data)
          LeadClientContact.create(contact_id: @contact.id, contactable: @lead)
        end
      end
    else
      flash.now[:danger] = @lead.errors.full_messages.join(",")
      @error = @lead.errors.any?
      @users = User.all
      @lead = Lead.new(lead_params)
      @lead.contacts.build
      @klass = Klass.find_by(name: "Lead")
      @groups = Group.includes(:fields).where(klass: @klass)
      @fields = current_user.fields_for_table_with_order(klass: @klass)
      @data = {user_id: User.all.pluck(:first_name, :id)}
      fields = Field.where(klass: @klass, have_custom_value: true)
      fields.each do |field|
        @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
      end
    end
    @leads = Lead.all
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @data = {user_id: User.all.pluck(:first_name, :id)}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def update
    @users = User.all
    @lead = Lead.find(params[:id])
    if @lead.update(lead_params)
      flash[:success] = 'Lead Successfully Updated!'
    else
      flash[:danger] = @lead.errors.full_messages.join(",")
    end
    @leads = Lead.all
    @klass = Klass.find_by(name: "Lead")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def assign_all
    Lead.where(id: params[:ids]).update_all(user_id: User.find(params[:assign_to]).id)
    @leads = Lead.all
    @klass = Klass.find_by(name: "Lead")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @data = {user_id: User.all.pluck(:first_name, :id)}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def destroy
    @lead = Lead.find(params[:id])
    if @lead.destroy
      flash[:success] = 'Lead Successfully Deleted!'
    else
      flash[:danger] = @lead.errors.full_messages.join(",")
    end
    @leads = Lead.all
    @klass = Klass.find_by(name: "Lead")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @data = {user_id: User.all.pluck(:first_name, :id)}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  def destroy_all
    @leads = Lead.where(id: params[:ids])
    if @leads.destroy_all
      flash[:success] = 'Selected Leads Successfully Deleted!'
    else
      flash[:danger] = 'Something Went Wrong While Deleting Selected Leads!'
    end
    @leads = Lead.all
    @klass = Klass.find_by(name: "Lead")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @data = {user_id: User.all.pluck(:first_name, :id)}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end

  #get form from the pop-up
  def import_form
    respond_to do |format|
      format.js
      format.html
    end
  end

  #post mothod to import data
  def import_file
    @document = Document.find(params[:document_id])
    @errors = Lead.import(@document.attachment, params[:fields].permit!.to_h, @document.id, current_user.id)
    if @errors.present?
      flash[:danger] = @errors.join(",")
    else
      flash[:success] = 'CSV Imported Successfully!'
    end
    redirect_to leads_path
  end

  def import_map
    @document = Document.create(attachment: params[:import], resourcable: current_user)
    @headers = CSV.open(params[:import].path, encoding: 'iso-8859-1:utf-8', &:readline)
    @klass = Klass.find_by(name: "Lead")
    @fields = Field.where(klass: @klass).where.not(group_id: nil)
    @data =  CSV.read(params[:import].path, :headers=>true, encoding: 'iso-8859-1:utf-8')
    @sample_data = @data[0]
    @errors = false
  end

  def convert_client
    @lead = Lead.find(params[:id])
    @users = User.all
    @client = Client.new
    @klass = Klass.find_by(name: 'Client')
    user_details = @users.pluck(:first_name, :id)
    @data = {user_id: user_details}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
    @lead.validate_for_client_conversion
    if @lead.errors.any?
      flash.now[:danger] = @lead.errors.full_messages.join(', ')
    end
  end

  def import_leads
    @klass = Klass.find_by(name: "Lead")
    @import_data_csvs = current_user.import_data_csvs.where(klass_id: @klass.id).order(created_at: :desc)
  end

  private

  def lead_params
    @klass = Klass.find_by(name: "Lead")
    params.require(:lead).permit(@klass.fields.pluck(:name), multi_select_params_permit(@klass))
  end

  def custom_value_params
    params.require(:lead).permit(custom_values_attributes: %i[id value field_id])
  end

  def field_params
    params.require(:lead).permit(fields_attributes: %i[id name column_type value fieldable_type])
  end

  def client_contacts_params
    @klass = Klass.find_by(name: "Lead")
    params.require(:lead).permit(contacts_attributes: {})
  end
end
