class TaskWorker
  include Sidekiq::Worker

  def perform(task_id)
    TaskMailer.email_reminder(Task.find(task_id)).deliver
  end
end
