class Users::TimeSheetLogsMailer < ApplicationMailer
  helper ApplicationHelper

  def build_email
    @setting = User::TimeSheetLog::EmailSetting.get_record
    mail(to: @setting.recipient_emails, subject: 'Important: Timesheet Report')
  end
end
