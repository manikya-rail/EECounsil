class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from("chat_channel_"+params[:room])
  end

  def unsubscribed
    stop_all_streams
  end
end
