class ChannelsController < ApplicationController
  accept_api_auth :post_msg

  skip_before_action :check_if_login_required, :check_password_change, :only => [:info, :session_info]

  def info
    ws_mode = "websocket-rails"
    if Rails::VERSION::MAJOR >= 5
      ws_mode = "actioncable"
    end
    render json: {ws_mode: ws_mode}
  end

  def session_info
    ws_mode = "websocket-rails"
    if Rails::VERSION::MAJOR >= 5
      ws_mode = "actioncable"
    end
    render json: {ws_mode: ws_mode, user: User.current ? User.current.login : null}
  end

  def post_msg
    if !User.current or User.current.login == "" then
      raise ::Unauthorized
    end

		msg = params.except(:id)
    RedmineRt::Broadcaster.broadcast params[:id], msg
    render status: 204, body: nil
  end
end
