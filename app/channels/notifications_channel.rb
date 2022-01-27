class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications:#{current_user.id}"
    puts "coneected#{current_user}"
  end

  def unsubscribed
    stop_all_streams
  end
end
