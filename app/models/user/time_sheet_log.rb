class User::TimeSheetLog < ApplicationRecord
  DAYNAMES = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]

  AUTO_CLOCK_OUT_IN = 10.hours
  CREATE_NEW_LOG_OFFSET = 6.hours

  belongs_to :user

  has_many :break_logs, dependent: :destroy

  accepts_nested_attributes_for :break_logs, allow_destroy: true

  validates :base_date, presence: true, uniqueness: { scope: :user }

  def clock_in_and_clock_out?
    clock_in_datetime? && clock_out_datetime?
  end

  def total_hours
    clock_in_and_clock_out? ? (clock_out_datetime - clock_in_datetime) : nil
  end

  def total_break_hours
    clock_in_and_clock_out? ? break_logs.map{|break_log| break_log.end_datetime - break_log.start_datetime}.sum : nil
  end

  def total_work_hours
    clock_in_and_clock_out? ? (total_hours - total_break_hours) : nil
  end

  def self.create_clock_in_log(user)
    self.transaction do
      user.schedule_auto_clock_out_at!(AUTO_CLOCK_OUT_IN.from_now) unless user.clocked_in?
      yesterday_log = user.time_sheet_logs.find_by(base_date: Date.yesterday)
      if need_to_create_new_log?(yesterday_log, DateTime.current)
        time_sheet_log = user.time_sheet_logs.find_or_create_by(base_date: Date.current)
        if !time_sheet_log.clock_in_datetime?
          time_sheet_log.update!(clock_in_datetime: DateTime.current)
        end
      end
    end
  end

  def self.create_clock_out_log(user)
    self.transaction do
      user.deschedule_auto_clock_out! if user.clocked_in?
      today_time_sheet_log = user.time_sheet_logs.find_by(base_date: Date.current)
      if today_time_sheet_log.present? # Day shift
        user.time_sheet_logs.find_by(base_date: Date.current).update!(clock_out_datetime: DateTime.current)
      else                             # Night shift
        user.time_sheet_logs.find_by(base_date: Date.yesterday).update(clock_out_datetime: DateTime.current)
      end
    end
  end

  # Also handles Day and Night shift more wisely
  def self.need_to_create_new_log?(yesterday_log, current_datetime)
    if !yesterday_log.present?
      return true
    end
    if !(yesterday_log.clock_in_datetime? && yesterday_log.clock_out_datetime?)
      return true
    end
    return (current_datetime.to_i - yesterday_log.clock_out_datetime.to_i) > CREATE_NEW_LOG_OFFSET
  end

  def self.with_date_group(range)
    records = {}
    chain = where(base_date: range)
    chain.each{|time_sheet_log| records[time_sheet_log.base_date] = time_sheet_log}
    range.each{|base_date| records[base_date].blank? ? records[base_date] = chain.build(base_date: base_date) : nil}
    records.sort.to_h
  end

  def self.with_week_day_group(users, range)
    records = {}
    users.each do |user|
      time_sheet_logs = user.time_sheet_logs.where(base_date: range)
      records[user] = {
        total_hours_of_week_day: time_sheet_logs.group_by{|time_sheet_log| time_sheet_log.base_date.strftime('%A')}.transform_values{|values| values.map{|time_sheet_log| time_sheet_log.total_work_hours}.compact.sum},
        total_work_hours: time_sheet_logs.map{|time_sheet_log| time_sheet_log.total_work_hours}.compact.sum
      }
    end
    records
  end
end
