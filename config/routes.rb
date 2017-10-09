# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# cable for redmine_rt

if Rails::VERSION::MAJOR >= 5
	mount ActionCable.server => '/cable' 
end

get '/journals/:id', to: 'journals#show'

put '/issues/:id/add_quick_notes', to: 'issues#add_quick_notes'
