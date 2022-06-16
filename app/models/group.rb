# Group attributes:
# id
# name
# label
# klass_id
# position (refers to: position in klass)
# hint
# created_at
# updated_at
# default
# deleted_at

class Group < ApplicationRecord
  audited
  has_ancestry orphan_strategy: :rootify

  default_scope { order(:position) }

  belongs_to :klass

  has_many :fields, dependent: :destroy
  has_many :role_resources, as: :resource, dependent: :destroy
  has_many :fields_with_selected_columns, -> { where(column_type: %w[Checkbox Text]).select(:id, :name, :label, :group_id, :column_type) }, class_name: 'Field'

  before_create :create_role_resources

  USED_IN_IPOS_CENTER = [72, 73, 74, 75, 76, 77, 78, 79, 80].freeze

  def parent_label
    self.parent&.label
  end

  def self.root_groups_except(group)
    root_groups.where.not(id: group.id)
  end

  def self.root_groups
    roots
  end

  # TODO: we are showing the default groups while converting lead into client,
  #   So we have to remove this after new lead to client convert flow
  def self.defaults
    all.where(default: true)
  end

  # Used for rendering
  def field_picklist_valuable_fields
    fields.field_picklist_valuable
  end

  def create_role_resources
    Role.all.each do |role|
      Action.all.each do |action|
        self.role_resources.build(role: role, action: action)
      end
    end
  end
end
