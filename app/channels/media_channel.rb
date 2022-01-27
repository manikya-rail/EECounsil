class MediaChannel < ApplicationCable::Channel
  def subscribed
    stream_from "medianotes:#{current_user.id}"
    puts "coneected#{current_user}"
  end

  def unsubscribed
    stop_all_streams
  end
end
