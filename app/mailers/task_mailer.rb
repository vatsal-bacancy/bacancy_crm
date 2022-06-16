class TaskMailer < ApplicationMailer
  default from: ENV['FROM_EMAIL']

  def email_reminder(task)
    @task = task
    mail to: @task.user.email, subject: 'Task Reminder'
  end

end
