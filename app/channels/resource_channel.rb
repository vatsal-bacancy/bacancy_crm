class ResourceChannel < ApplicationCable::Channel
  def subscribed
    if params['resourceKlass'] && params['resourceId']
      stream_from "resource_channel_#{params['resourceKlass']}_#{params['resourceId']}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
