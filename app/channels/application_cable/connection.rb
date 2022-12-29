module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        token = nil

        if request.params[:access_key] then
          token = Token.find_by(action: :api, value: request.params[:access_key])
        end

        if not token then
          token = Token.find_by(action: :autologin, value: cookies[:autologin])
        end

        if not token then
          request.params[:unauthorized] = true
          return
    end

        if token and (verified_user = User.find(token.user_id)) then
          return verified_user
        else
          request.params[:unauthorized] = true
          return verified_user
        end
      end
  end

  private

  def report_error(e)
    puts("ApplicationCable::Connection report_error" + e)
  end
end
