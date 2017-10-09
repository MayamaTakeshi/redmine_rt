module RedmineRt
  class MessagesChannel < ApplicationCable::Channel
    def subscribed
      if current_user[:unauthorized] then
        stream_from "unauthorized"
        ActionCable.server.broadcast "unauthorized", {"event": "error", "type": "unauthorized"}
      else
        stream_from "issue-#{params['issue_id']}:messages"
      end
   end
  end
end
