# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# cable for redmine_rt

if Rails::VERSION::MAJOR >= 5
	mount ActionCable.server => Redmine::Utils::relative_url_root + '/cable' 
end

get '/journals/:id', to: 'journals#show'

delete '/journals/:id', to: 'journals#destroy'

put '/issues/:id/add_quick_notes', to: 'issues#add_quick_notes'

get '/channels/info', to: 'channels#info'

get '/channels/session_info', to: 'channels#session_info'

post '/channels/:id/post_msg', to: 'channels#post_msg'

post '/channels/:id/post_msg_by_session', to: 'channels#post_msg_by_session'

get '/realtime', to: 'realtime#index'
