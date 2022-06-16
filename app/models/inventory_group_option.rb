class InventoryGroupOption < ApplicationRecord
  belongs_to :attribute_option
  belongs_to :inventory_group

  PERMITTED_PARAMS = [:id, :attribute_option_id, :_destroy, options: []]


  def options_string
    options.join(', ')
  end
end
