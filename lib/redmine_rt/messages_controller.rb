module RedmineRt
  class MessagesController < WebsocketRails::BaseController
 
    def client_connected
      puts "got client_connected"
    end
  end
end
