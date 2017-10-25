module RedmineRt
  class UsersChannel < ApplicationCable::Channel
    def subscribed
      if not current_user or current_user[:unauthorized] then
        stream_from "unauthorized"
        ActionCable.server.broadcast "unauthorized", {"event": "error", "type": "unauthorized"}
      else
        stream_from "user:#{params['user_login']}:messages"
      end
   end
  end
end
