class ActionCableWorker
  include Sidekiq::Worker

  def perform(opts={})
    ActionCable.server.broadcast "resource_channel_#{opts['resource_klass']}_#{opts['resource_id']}", 'reload_messages'
  end
end
