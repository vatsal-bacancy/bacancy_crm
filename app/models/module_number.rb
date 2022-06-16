class ModuleNumber < ApplicationRecord
  audited
  belongs_to :klass
end
