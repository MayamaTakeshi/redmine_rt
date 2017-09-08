# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# cable for redmine_rt
mount ActionCable.server => '/cable' 

get '/journals/:id', to: 'journals#show'
