class ImportDataCsv < ApplicationRecord
  belongs_to :user
  belongs_to :document
  belongs_to :klass
end
