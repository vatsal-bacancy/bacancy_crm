class User < ApplicationRecord
  audited except: :direct_otp

  rolify

  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  mount_uploader :profile_picture, AttachmentUploader

  scope :active, -> { where.not(encrypted_password: '') }
  scope :ordered, -> { order(:fullname) }

  has_many :leads, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :vendors, foreign_key: 'assigned_to_id', dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :owned_tickets, foreign_key: 'owner_id', class_name: 'Ticket', dependent: :destroy
  has_many :ticket_users, dependent: :destroy
  has_many :associated_tickets, through: :ticket_users, source: :ticket
  has_many :unreads, as: :resourcable, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :inventory_groups, dependent: :destroy
  has_many :inventories, dependent: :destroy
  has_many :client_inventory_associations, class_name: 'Client::InventoryAssociation', foreign_key: :created_by_id, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :brands, dependent: :destroy
  has_many :merchants, dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  has_many :directories
  has_many :import_data_csvs
  has_many :email_templetes
  has_many :messages, as: :resourcable, dependent: :destroy
  has_many :directories, as: :resourcable, dependent: :destroy
  has_many :documents, as: :resourcable, dependent: :destroy
  has_many :file_manager_folders, as: :owner, class_name: 'FileManager::Folder', dependent: :destroy
  has_many :file_manager_files, as: :owner, class_name: 'FileManager::File', dependent: :destroy
  has_many :attendees, as: :resourceable, class_name: 'Meetings::Attendee', dependent: :destroy
  has_many :meetings, class_name: 'Meetings::Meeting', dependent: :destroy # meeting as owner
  has_many :field_preferences, class_name: 'User::FieldPreference', dependent: :destroy
  has_many :contracts, class_name: 'Contract::Contract', dependent: :destroy
  has_many :purchase_order_versions, class_name: 'PurchaseOrder::Version', foreign_key: :created_by_id, dependent: :destroy
  has_many :time_sheet_logs, class_name: 'User::TimeSheetLog', dependent: :destroy
  has_many :client_task_logs, dependent: :destroy

  has_one :user_permission, dependent: :destroy

  before_save :assign_default_role
  after_create :assign_projects
  after_create :set_user_role
  after_create :build_field_preferences
  before_save :set_fullname

  def self.tfa_valid_phone_numbers
    User::TfaPhoneNumber.all.pluck(:number)
  end

  def send_direct_otp(phone_number)
    otp = rand(1000...9999).to_s
    update!(direct_otp: otp)
    SMSWorker.perform_async(to: phone_number, body: "Your OTP is #{otp}")
  end

  def verify_direct_otp(otp)
    if self.direct_otp == otp
      update!(direct_otp: nil)
      return true
    end
    false
  end

  def schedule_auto_clock_out_at!(datetime)
    UserWorker.perform_at(datetime, 'run_scheduled_auto_clock_out', self.id)
    self.update!(auto_clock_out_at: datetime)
  end

  def deschedule_auto_clock_out!
    self.update!(auto_clock_out_at: nil)
  end

  def clocked_in?
    auto_clock_out_at?
  end

  def google_token_expired?
    Time.current > google_token_expired_at rescue true
  end

  def send_login_instructions(current_user)
    InvitationWorker.perform_async(:user_login_instructions, user_id: id, current_user_id: current_user.id)
  end

  def send_account_setup_instructions(current_user)
    token = set_reset_password_token
    InvitationWorker.perform_async(:user_account_setup_instructions, user_id: id, token: token, current_user_id: current_user.id)
  end

  def all_user_of_related_company
    User.all.active.ordered
  end

  def self.all_active_users
    User.all.active.ordered
  end

  def active?
    encrypted_password != ''
  end

  def reference_export
    fullname
  end

  def self.reference_import(fullname)
    raise ActiveRecord::RecordNotFound.new('User must exist') unless fullname
    name = fullname.split(' ')
    self.find_by!(first_name: name[0], last_name: name[1])
  end

  # TODO: use active model relation instead
  def company
    @company ||= Company.first
  end

  # Used only in KPIs controller
  def clients_id_and_company_name
    clients.to_json(only: [:id, :company_name])
  end

  # TODO: We are using one role per user so, remove roles relation
  def role
    self.roles.first
  end

  def is_super_admin?
    self.has_cached_role?(:super_admin)
  end

  # As per: https://stackoverflow.com/a/39478498
  # Or we can use .includes() instead of .joins() for order as per other answers
  def fields_for_table_with_order(klass:)
    klass.fields.joins(:user_field_preferences).merge(field_preferences.where(visible_in_table: true).order_by_position_in_table)
  end

  # This will gives all field preference of given klass only
  def field_preferences_of_klass(klass:)
    field_preferences.where(field: klass.fields)
  end

  def to_polymorphic
    "User:#{id}"
  end

  def destroy_and_migrate_date_to(user)
    return if self == user
    User.transaction do
      self.leads.update_all(user_id: user.id)
      self.clients.update_all(user_id: user.id)
      self.vendors.update_all(assigned_to_id: user.id)
      self.tasks.update_all(user_id: user.id)
      self.notes.update_all(user_id: user.id)
      self.owned_tickets.update_all(owner_id: user.id)
      self.ticket_users.update_all(user_id: user.id)
      self.comments.update_all(user_id: user.id)
      self.inventory_groups.update_all(user_id: user.id)
      self.inventories.update_all(user_id: user.id)
      self.client_inventory_associations.update_all(created_by_id: user.id)
      self.categories.update_all(user_id: user.id)
      self.project_users.update_all(user_id: user.id)
      self.directories.update_all(resourcable_id: user.id)
      self.import_data_csvs.update_all(user_id: user.id)
      self.email_templetes.update_all(user_id: user.id)
      self.messages.update_all(resourcable_id: user.id)
      self.documents.update_all(resourcable_id: user.id)
      self.file_manager_folders.update_all(owner_id: user.id)
      self.file_manager_files.update_all(owner_id: user.id)
      self.attendees.update_all(resourceable_id: user.id)
      self.meetings.update_all(user_id: user.id)
      self.contracts.update_all(user_id: user.id)
      self.purchase_order_versions.update_all(created_by_id: user.id)
      self.destroy
    end
  end

  def clients_groups(klass)
    task_group = []
    # self.role&.readable_root_groups(klass: klass)&.each do |group|
    groups = klass.groups.where.not(ancestry: nil).includes(:fields_with_selected_columns)
    groups.each do |group|
      group_hash = {}
      # NOTE: We're taking fields which have column_type of `Checkbox` and `Text`.
      fields = group.fields_with_selected_columns.as_json
      next if fields.blank?

      group_hash['task_id'] = group.id
      group_hash['is_checked_in'] = false
      group_hash['is_checked_out'] = false
      group_hash['is_employee_submitted'] = false
      group_hash['checklist_name'] = group.label
      group_hash['checklist_date'] = group.created_at.strftime('%Y-%m-%d')
      group_hash['sub_task'] = fields
      task_group << group_hash
    end
    # end
    task_group
  end

  protected

  def password_required?
    return false
  end

  private

  def assign_default_role
    self.add_role(:employee) if self.roles.blank?
  end

  def assign_projects
    ProjectAssignee.where(email: self.email).update_all(user_id: self.id)
  end

  def set_user_role
    role = self.roles.first
    attrs = %w(action_id klass_id)
    permissions = role.role_permissions.pluck(*attrs).map { |p| attrs.zip(p).to_h }
    self.build_user_permission(permissions: permissions).save
  end

  # Build user preference for existing fields
  # And as of now make system field visible in table
  def build_field_preferences
    Field.all.each do |field|
      field_preference = field_preferences.build(field: field)
      field_preference.make_visible_in_table if field.system_field
    end
  end

  def set_fullname
    self.fullname = "#{first_name} #{last_name}".strip
  end
end
