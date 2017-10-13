class ChannelsController < ApplicationController
  accept_api_auth :post_msg

  def post_msg
    puts "post_message"
    puts params
    RedmineRt::Broadcaster.broadcast params[:id], params[:msg]
    render status: 204, body: nil
  end
end
