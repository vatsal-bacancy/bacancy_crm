class FieldPicklistValue < ApplicationRecord
  audited

  default_scope { order(:position) }

  belongs_to :field

  before_update :update_records_to_new_value
  before_destroy :update_records_to_nil

  CLASS_MAP = {Lead => Client} # used to create same value in opposite model

  def create_value_in_opposite_class
    if FieldPicklistValue::CLASS_MAP[self.field.klass.constant] # create value in opposite model, see field_picklist_value.rb for more info
      klass = Klass.find_by(name: FieldPicklistValue::CLASS_MAP[self.field.klass.constant].name)
      field = klass.fields.find_by(name: self.field.name)
      return unless field
      field.field_picklist_values.create(value: self.value)
    end
  end

  private

  def update_records_to_new_value
    field.klass.constant.where(field.name => value_was).update_all(field.name => value) if value_changed?
  end

  def update_records_to_nil
    field.klass.constant.where(field.name => value).update_all(field.name => nil)
  end
end
