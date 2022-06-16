class SMSWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(args)
    phone_numbers = args['to'].split(',').uniq.select { |to| to.present? }
    body = args['body']
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    phone_numbers.each do |to|
      client.messages.create(from: ENV['TWILIO_FROM_NUMBER'], to: to, body: body) rescue nil
    end
  end
end
