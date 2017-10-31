module RedmineRt
  class Channel < ApplicationCable::Channel
    def subscribed
      if not current_user or current_user[:unauthorized] then
        stream_from "unauthorized"
        ActionCable.server.broadcast "unauthorized", {"event": "error", "type": "unauthorized"}
      else
        if not params['name'] or params['name'] == '' then		
          stream_from "unauthorized"
          ActionCable.server.broadcast "unauthorized", {"event": "error", "type": "no_channel_specified"}
        else
       	  stream_from params['name']
        end
      end
   end
  end
end
