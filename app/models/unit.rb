class Unit < ApplicationRecord

  def reference_export
    messure
  end

  def self.reference_import(messure)
    self.find_by!(messure: messure)
  end
end
