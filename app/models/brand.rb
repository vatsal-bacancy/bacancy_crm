class Brand < ApplicationRecord
  belongs_to :user

  def reference_export
    name
  end

  def self.reference_import(name)
    self.find_by!(name: name)
  end
end
