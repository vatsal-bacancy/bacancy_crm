class User::TimeSheetLog::BreakLog < ApplicationRecord
  belongs_to :time_sheet_log

  validates :start_datetime, :end_datetime, presence: true
end
