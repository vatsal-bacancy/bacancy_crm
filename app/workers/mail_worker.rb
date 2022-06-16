class MailWorker
  include Sidekiq::Worker

  def perform(args)
    ActionMailer::Base.mail(
      from: ENV['FROM_EMAIL'],
      to: args['to'],
      cc: args['cc'],
      bcc: args['bcc'],
      subject: args['subject'],
      body: args['body'],
      content_type: "text/html"
    ).deliver
  end
end
