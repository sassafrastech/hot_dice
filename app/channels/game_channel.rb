class GameChannel < ApplicationCable::Channel
  def subscribed
    channel_name = "game:#{params[:game_code]}"
    puts "channel name: #{channel_name}"
    stream_from(channel_name)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def say(data)
    message = data.without("action")
    broadcast_to(params[:game_code], message)
  end
end
