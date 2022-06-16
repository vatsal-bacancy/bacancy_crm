# Field attributes:
# name
# label
# column_type
# klass
# position (refers to: position in group)
# placeholder
# min_length
# max_length
# default_value
# required
# quick_create
# key_field_view
# mass_edit
# deletable
# system_field
# group
# custom (we can replace this with the `!system_field`)
# reference
# reference_klass
# reference_key
# have_custom_value

class Field < ApplicationRecord
  audited

  default_scope { order(:position) }
  scope :quick_creatable, -> { where(quick_create: true) }

  belongs_to :group, optional: true
  belongs_to :klass

  has_many :field_picklist_values, dependent: :destroy
  has_many :work_flows_and_conditions, class_name: 'WorkFlows::AndCondition', dependent: :destroy
  has_many :work_flows_or_conditions, class_name: 'WorkFlows::OrCondition', dependent: :destroy
  has_many :user_field_preferences, class_name: 'User::FieldPreference', dependent: :destroy
  has_many :client_fields, dependent: :destroy
  has_many :clients, through: :client_fields

  # For column_type `File`
  has_many :file_manager_file_associations, class_name: 'FileManager::FileAssociation', dependent: :destroy

  before_create :build_user_field_preferences

  validates_uniqueness_of :name, :scope => :klass_id

  # TODO: FIXME: Checkbox column type should be booleans instead of text
  # We may have to set default value for checkbox to `false`, because search can be easier, see ApplicationHelper#pretty_checkbox for more
  TYPE_CAST = {"Text"=> "text", "Decimal"=> "decimal", "Integer"=> "integer", "Percent"=> "float", "Currency"=> "decimal", "Date"=> "date", "Email"=> "text", "Phone"=> "text", "Picklist"=> "text", "URL"=> "text", "Checkbox"=> "text", "Text Area HTML"=>"text", "Multi-Select Check Box"=>"text", "Skype"=>"text", "Time"=>"time", "DateTime" => "datetime", "File" => 'file', 'Text Area' => 'text', 'Label' => 'text', 'Radio Button' => 'string'}
  PATTERNS =  {
    Text: nil,
    Decimal: '\d+(\.\d+)?',
    Integer:' \d+',
    Percent: '\d+(?:\.\d+)?%',
    Currency: nil,
    Date: '(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])\/(19|20)\d{2}',
    Email: '^.+@.+$',
    Phone: '((\(\d{3}\) ?)|(\d{3}-))?\d{3}-\d{4}',
    Picklist: '//',
    URL: '[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)',
    Checkbox: '//',
    Text_Area:'//',
    Multi_Select_Combo_Box: '//',
    Skype: '[a-zA-Z][a-zA-Z0-9\.,\-_]{5,31}',
    Time: '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))',
    field: '\w*',
    DateTime: '//'
  }
  CLASS_MAP = {Lead => Client} # used to create same column in opposite model

  def is_picklist?
    column_type == 'Picklist'
  end

  def is_date_time?
    column_type == 'DateTime'
  end

  def is_date?
    column_type == 'Date'
  end

  def is_date_or_date_time?
    is_date? || is_date_time?
  end

  def field_picklist_value_of(object)
    field_picklist_values.detect { |field_picklist_value| field_picklist_value.value == object.send(self.name) }
  end

  # Stands for the field that have values in `FieldPicklistValue`
  def self.field_picklist_valuable
    all.where(column_type: ['Picklist', 'Multi-Select Check Box', 'Radio Button'],  have_custom_value: true)
  end

  def create_column
    return if self.column_type == 'File'
    executor = SqlExecutor.new(self.klass.constant)
    executor.create_column(name: self.name, type: TYPE_CAST[self.column_type])
  end

  def destroy_column
    return if self.column_type == 'File'
    executor = SqlExecutor.new(self.klass.constant)
    executor.destroy_column(name: self.name)
  end

  def self.build(params)
    field = Field.new(params)
    field.position = field.group.fields.any? ? field.group.fields.pluck(:position).compact.max + 1 : 0
    field.name = params[:label].snakecase[0...63]
    field.have_custom_value = true # TODO: This is wrong we have to remove this
    field
  end

  def user_preference(user:)
    user_field_preferences.find_by(user: user)
  end

  # Build field preference for existing users
  def build_user_field_preferences
    User.all.each do |user|
      user_field_preferences.build(user: user)
    end
  end
end
