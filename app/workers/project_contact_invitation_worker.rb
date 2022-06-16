class ProjectContactInvitationWorker
  include Sidekiq::Worker

  def perform(type,opts={})
    #ProjectContactInvitationMailer.send(type, opts).deliver
  end
end
