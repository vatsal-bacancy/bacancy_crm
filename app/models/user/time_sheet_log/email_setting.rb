class User::TimeSheetLog::EmailSetting < ApplicationRecord
  DEFAULT_SCHEDULE = '0 0 1,16 * *'

  validates :recipients, presence: true
  validates :days_range, presence: true
  validates :recurrence_schedule, presence: true

  after_save :create_recurrence_job

  def since_days
    days_range
  end

  def recipient_emails
    recipients
  end

  def time_sheet_logs
    User::TimeSheetLog.with_week_day_group(User.all_active_users, Date.current.days_ago(days_range)..Date.current)
  end

  def valid_emails
    User.all_active_users.pluck(:email)
  end

  def valid_days_range
    [ ['7 Days', 7], ['15 Days', 15], ['30 Days', 30] ]
  end

  def create_recurrence_job
    Sidekiq::Cron::Job.destroy(self.to_gid_param)
    Sidekiq::Cron::Job.create(name: self.to_gid_param, cron: recurrence_schedule, class: 'Users::TimeSheetLogsWorker', args: ['send_email'])
  end

  # As we knows we only gonna have one record
  def self.get_record
    self.first_or_initialize(recurrence_schedule: DEFAULT_SCHEDULE)
  end
end
