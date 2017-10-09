module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        token = Token.find_by(action: :autologin, value: cookies[:autologin])
        if not token then
          reject_unauthorized_connection
          return
	end
        if verified_user = User.find(token.user_id) then
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
