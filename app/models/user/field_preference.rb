# User::FieldPreference attributes:
# position_in_table
# visible_in_table
# field
# user

class User::FieldPreference < ApplicationRecord
  scope :order_by_position_in_table, -> { reorder(:position_in_table) }

  belongs_to :field
  belongs_to :user

  before_save :apply_correct_visibility_in_table

  def make_visible_in_table
    maximum = get_relevant_preferences.maximum(:position_in_table)
    position = maximum.present? ? (maximum + 1) : 0 # Because if nothing is visible in the table then maximum will be `nil`
    update(position_in_table: position)
  end

  def make_invisible_in_table
    return unless visible_in_table
    get_relevant_preferences.where('position_in_table > :position_in_table', position_in_table: position_in_table).each do |field_preference|
      field_preference.update(position_in_table: field_preference.position_in_table - 1)
    end
    update(position_in_table: nil)
  end

  def apply_correct_visibility_in_table
    self.visible_in_table = position_in_table.present?
  end

  private

  # Get all related field preferences of klass of user
  def get_relevant_preferences
    user.field_preferences_of_klass(klass: field.klass)
  end
end
