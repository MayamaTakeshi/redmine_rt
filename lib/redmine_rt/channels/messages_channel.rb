module RedmineRt
  class MessagesChannel < ApplicationCable::Channel
    def subscribed
      stream_from "issue-#{params['issue_id']}:messages"
   end
  end
end
