# This feature could break because this depends on dynamic fields it could break the application, if deleted
class Client::StatusBoard::Base < ApplicationRecord
  include ApplicationHelper

  delegate :company_name, :state, :user, :created_at, :account_service_type_, to: :client, prefix: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :active, -> {
    merge(Client.where(lead_status: CLIENT_STATUS_ACTIVE))
  }
  belongs_to :client

  validates :client, uniqueness: true

  DEPARTMENTS = {
    client_boarding_qa: { assigned_to_field: 'boarding__assign__to', status_field: 'boarding_qa_status', start_date_field: :boarding_qa_start_date, end_date_field: :boarding_qa_end_date },
    client_inventory_allocation: { assigned_to_field: 'inventory_allocation_assigned_to', status_field: 'inventory_status', start_date_field: :inventory_allocation_start_date, end_date_field: :inventory_allocation_end_date },
    client_due_diligence: { assigned_to_field: 'due__diligence__assigned__to', status_field: 'due_diligence_status', start_date_field: :due_diligence_start_date, end_date_field: :due_diligence_end_date },
    client_menu_india: { assigned_to_field: 'menu__assigned__to', status_field: 'menu_status', start_date_field: :menu_india_start_date, end_date_field: :menu_india_end_date },
    client_menu_usa: { assigned_to_field: 'menu_us_assigned_to', status_field: 'menu_us_status', start_date_field: :menu_usa_start_date, end_date_field: :menu_usa_end_date },
    client_olo: { assigned_to_field: 'due__diligence__assigned__to', status_field: 'website_status', start_date_field: :olo_start_date, end_date_field: :olo_end_date },
    client_deployment: { assigned_to_field: 'deployment__assigned__to_', status_field: 'deployment_status', start_date_field: :deployment_start_date, end_date_field: :deployment_end_date },
    qr_code_for_order_taking: { assigned_to_field: 'qr_code_for_url_order_taking_assigned_to', status_field: 'qr_code_for_url_order_taking_status', start_date_field: :qr_code_order_taking_start_date, end_date_field: :qr_code_order_taking_end_date },
    eats_business_website_setup: { assigned_to_field: 'eats_business_website_setup_assign_to', status_field: 'eats_business_website_setup_status', start_date_field: :eats_business_website_setup_start_date, end_date_field: :eats_business_website_setup_end_date },
    eats_app_setup: { assigned_to_field: 'ipos_eats_app_setup_assign_to', status_field: 'ipos_eats_app_setup_status', start_date_field: :ipos_eats_app_setup_start_date, end_date_field: :ipos_eats_app_setup_end_date },
    hq_po: { assigned_to_field: 'hq_po_assigned_to', status_field: 'hq_po_status', start_date_field: :hq_po_start_date, end_date_field: :hq_po_end_date },
    client_pre_install: { assigned_to_field: 'pre_installation_assigned_to', status_field: 'pre_installation_status', start_date_field: :pre_installation_start_date, end_date_field: :pre_installation_end_date },
    client_pre_training: { assigned_to_field: 'pre_training_assigned_to', status_field: 'pre_training_status', start_date_field: :pre_training_start_date, end_date_field: :pre_training_end_date },
    client_employee_training: { assigned_to_field: 'employee_training_assigned_to', status_field: 'employee_training_status', start_date_field: :employee_training_start_date, end_date_field: :employee_training_end_date },
    client_owner_backoffice_training: { assigned_to_field: 'owner_manager_ipos_back_office_training_assigned_to', status_field: 'owner_manager_ipos_back_office_training_status', start_date_field: :owner_manager_ipos_back_office_training_start_date, end_date_field: :owner_manager_ipos_back_office_training_end_date },
    qa_by_pos_management: { assigned_to_field: 'qa_by_pos_management_assigned_to', status_field: 'qa_by_pos_management_status', start_date_field: :qa_by_pos_management_start_date, end_date_field: :qa_by_pos_management_end_date }
  }

  ASSIGNED_TO_OBSERVABLE_FIELDS = DEPARTMENTS.values.pluck(:assigned_to_field)
  STATUS_OBSERVABLE_FIELDS = DEPARTMENTS.values.pluck(:status_field)

  STATUS_FIELD_CHANGED_TO = 'Completed'

  CLIENT_STATUS_ACTIVE = 'Production Mode'

  NOT_SKIP_OLO_DEPARTMENT_WHEN = 'olo'

  def self.departments_by(department_name: nil, assigned_to_field: nil, status_field: nil)
    DEPARTMENTS.select { |department, fields| department == department_name || fields[:assigned_to_field] == assigned_to_field || fields[:status_field] == status_field }
  end

  # Set department start_date when assigned field set to something and
  #   set end_date when status field set to something
  def update_observable_fields
    (client.changed & ASSIGNED_TO_OBSERVABLE_FIELDS).each do |observable_field|
      update_to = client.send(observable_field).present? ? DateTime.current : nil
      self.class.departments_by(assigned_to_field: observable_field).each do |department, fields|
        update(fields[:start_date_field] => update_to)
      end
    end
    (client.changed & STATUS_OBSERVABLE_FIELDS).each do |observable_field|
      update_to = (client.send(observable_field).strip == STATUS_FIELD_CHANGED_TO) ? DateTime.current : nil
      self.class.departments_by(status_field: observable_field).each do |department, fields|
        update(fields[:end_date_field] => update_to)
      end
    end
  end

  def self.client_company_name_field_name
    'company_name'
  end

  def self.client_user_id_field_name
    'user_id'
  end

  def self.client_user_fullname_field_name
    'fullname'
  end

  def self.ipos_agent_field_name
    'ipos_agent_name_'
  end

  def self.client_account_status_field_name
    'lead_status'
  end

  def self.client_ipos_username_field_name
    'ipos_username'
  end

  def self.client_ipos_password_field_name
    'ipos_password'
  end

  # Overloading the `deployment_start_date` and `deployment_end_date`
  #   Because we have to show start date and end date of deployment department as per their `meetings` in the `client`
  def deployment_start_date
    client.meetings.first&.start_date_time
  end

  def deployment_end_date
    client.meetings.first&.end_date_time
  end

  def deployment_start_date=(date)
  end

  def deployment_end_date=(date)
  end

  # We are skip rendering of `olo` department if client's `account_service_type_` is not `olo`
  def skip_department?(department)
    return false if department != :client_olo
    client_account_service_type_.to_s.exclude?(NOT_SKIP_OLO_DEPARTMENT_WHEN)
  end

  def late_time_taken_by_departments?
    time_taken_by_departments.to_i > 7
  end

  def calculate_time_taken_by_departments
    department_times = []
    DEPARTMENTS.each do |department, fields|
      if (start_date = send(fields[:start_date_field])).present? && (end_date = send(fields[:end_date_field])).present? && !skip_department?(department)
        department_times.push((end_date.to_date - start_date.to_date).to_i)
      end
    end
    department_times.sum
  end

  def time_taken_by_departments
    @time_taken_by_departments ||= calculate_time_taken_by_departments
  end

  def pretty_time_taken_by_departments
    pretty_days_from_float(time_taken_by_departments)
  end
end
