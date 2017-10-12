module RedmineRt
  class AuthorizationController < WebsocketRails::BaseController

    def handle_subscribe
      channel = WebsocketRails[message[:channel]]
      channel.make_private
    end

    def handle_subscribe_private
      token = Token.find_by(action: :autologin, value: request.cookies["autologin"])
      if token then
        accept_channel
      else
        deny_channel({:event => "error", :details => "unauthorized"})
      end
    end
  end
end
