class MessagesChannel < ApplicationCable::Channel
  def subscribed
    logger.debug "subscribed"
    stream_from 'articles'
  end
end

