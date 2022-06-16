class MesssageWorker
  include Sidekiq::Worker

  def perform(type,opts={})
    MesssageMailer.send(type, opts.with_indifferent_access).deliver
  end
end
