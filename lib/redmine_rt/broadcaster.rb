module RedmineRt
  class Broadcaster
    class << self
      def broadcast(channel_name, data)
        if Rails::VERSION::MAJOR >= 5
          ActionCable.server.broadcast channel_name, data
        else
          WebsocketRails[channel_name].trigger('ALL', data)
        end
      end
    end
  end	
end
