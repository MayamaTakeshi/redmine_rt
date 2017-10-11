module RedmineRt
  class AuthorizationController < WebsocketRails::BaseController

    def handle_subscribe
      puts "handle_subscribe called"
      channel = WebsocketRails[message[:channel]]
      channel.make_private
    end

    def handle_subscribe_private
      puts "handle_subscribe_private called"

      puts request.cookies

      token = Token.find_by(action: :autologin, value: request.cookies["autologin"])
      puts "token: " + token.to_s
      if token then
        puts "token found: " + token.to_s
        accept_channel
      else
        puts "token not found"
        deny_channel({:event => "error", :details => "unauthorized"})
      end
    end
  end
end
