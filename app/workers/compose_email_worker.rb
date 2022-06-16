class ComposeEmailWorker
  include Sidekiq::Worker

  def perform(cemail_id,current_user_id)
    cemail = Cemail.find(cemail_id)
    user = User.find(current_user_id)
    ComposeEmailMailer.send_compose_email(cemail,user).deliver
  end
end
