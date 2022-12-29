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

    def receive(data)
      if data['command'] == "send_msg" then
        Broadcaster.broadcast(data['data']['channel_name'], data['data']['msg'])
      end
    end
end
