module RedmineRt
  class AuthorizationController < WebsocketRails::BaseController

    def handle_subscribe
      channel = WebsocketRails[message[:channel]]
      channel.make_private
    end

    def handle_subscribe_private
      token = nil

      if request.params[:access_key] then
        token = Token.find_by(action: :api, value: request.params[:access_key])
      end

      if not token then
        token = Token.find_by(action: :autologin, value: request.cookies["autologin"])
      end

      if token and User.find(token.user_id) then
        accept_channel
      else
        deny_channel({:event => "error", :details => "unauthorized"})
      end
    end

		def post_msg
      WebsocketRails[message[:channel_name]].trigger('ALL', message[:msg])
		end
  end
end
