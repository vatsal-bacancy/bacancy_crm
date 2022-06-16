class Users::TimeSheetLogsWorker
  include Sidekiq::Worker

  def perform(type)
    send(type)
  end

  def send_email
    Users::TimeSheetLogsMailer.build_email.deliver
  end
end
