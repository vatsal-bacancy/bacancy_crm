class InvitationWorker
  include Sidekiq::Worker

  # send invitation
  def perform(type, opts={})
    InvitationMailer.send(type, opts.with_indifferent_access).deliver
  end
end
