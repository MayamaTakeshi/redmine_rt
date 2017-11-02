# redmine_rt

This plugin works with Redmine 4 (using ActionCable) and 3 (using websocket-rails).


You must install dependency plugin redmine_base_deface:
```
cd plugins
git clone https://github.com/jbbarth/redmine_base_deface
```

Install it following usual plugin installation procedure:
```
cd plugins
git clone https://github.com/MayamaTakeshi/redmine_rt
```

Then:
```
cd ..
bundle install
```


***For Redmine 4***:

Install redis-server.
Then create file redmine/config/cable.yml with the following content:
```
development:
  adapter: redis
  url: redis://localhost:6379/1
  channel_prefix: redmine_rt

test:
  adapter: async

production:
  adapter: redis
  url: redis://localhost:6379/1
  channel_prefix: redmine_rt

```

Start server doing:
```
bundle exec rails server puma -e production -b 0.0.0.0

```


***For Redmine 3***

Add/create file redmine-3.X.X/config/events.rb with the following content:

```
WebsocketRails::EventMap.describe do
  namespace :websocket_rails do
    subscribe :subscribe, to: RedmineRt::AuthorizationController, with_method: :handle_subscribe

    subscribe :subscribe_private, to: RedmineRt::AuthorizationController, with_method: :handle_subscribe_private
  end
end
```

Open file redmine-3.X.X/config/application.rb and add config to delete Rack::Lock:
```
module RedmineApp
  class Application < Rails::Application
    ... ABRIDGED ...
    config.middleware.delete Rack::Lock
  end
end
```

Open file Redmine-3.X.X/plugins/redmine_rt/Gemfile and uncomment the following line:
```
gem 'websocket-rails', git: 'https://github.com/recurser/websocket-rails', branch: 'bugfix/388-latest-faye-websocket'
```

Start server doing:
```
bundle exec rails server thin -e production -b 0.0.0.0 
```
Obs: you must use server thin. Other servers like puma or webrick will not work.


Currently we just send notification of events (we don't send html fragments to clients) and this causes the client to update the page (making ajax calls if necessary).


I recommend to use:
  "My account" > Preferences > "Display comments" = "In reverse chronological order"
as this will make "quick_notes" to be put above history section that I think looks better than having it below it.


The plugin adds an API endpoint /channels/CHANNEL_NAME/post_msg.json to permit to send messages to channels. Usage:
  curl -v -x '' -u YOUR_API_TOKEN:fake -X POST -H 'Content-Type: application/json' http://REDMINE_IP_PORT/channels/sales/post_msg.json -d '{"msg": {"event": "customer_arrived"}}'


