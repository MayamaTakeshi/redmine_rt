class ChannelsController < ApplicationController
  accept_api_auth :post_msg

  skip_before_action :check_if_login_required, :check_password_change, :only => [:info]

  def info
    ws_mode = "websocket-rails"
    if Rails::VERSION::MAJOR >= 5
      ws_mode = "actioncable"
    end
    render json: {ws_mode: ws_mode}
  end

  def post_msg
    RedmineRt::Broadcaster.broadcast params[:id], params[:msg]
    render status: 204, body: nil
  end
end
