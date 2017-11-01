# redmine_rt

Requirement:
  redmine_base_deface >= '0.0.1'

This works with Redmine 4 (using ActionCable) and 3 (using websocket-rails).

Install it following usual plugin installation procedure.
Then:


***For Redmine 4***:
Create file redmine/app/cable.yml with the following content:
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

Add/create file redmine/config/events.rb with the following content:

```
WebsocketRails::EventMap.describe do
  namespace :websocket_rails do
    subscribe :subscribe, to: RedmineRt::AuthorizationController, with_method: :handle_subscribe

    subscribe :subscribe_private, to: RedmineRt::AuthorizationController, with_method: :handle_subscribe_private
  end
end
```
Open file config/application.rb and add config to delete Rack::Lock:
```
module RedmineApp
  class Application < Rails::Application
    ... ABRIDGED ...
    config.middleware.delete Rack::Lock
  end
end
```

Start server doing:
```
bundle exec rails server thin -e production -b 0.0.0.0 # other servers like puma or webrick will not work.
```


Currently we just send notification of events (we don't send html fragments to clients) and this causes the client to update the page (making ajax calls if necessary).


I recommend to use:
  "My account" > Preferences > "Display comments" = "In reverse chronological order"
as this will make "quick_notes" to be put above history section that I think looks better than having it below it.


The plugin adds an API endpoint /channels/CHANNEL_NAME/post_msg.json to permit to send messages to channels. Usage:
  curl -v -x '' -u YOUR_API_TOKEN:fake -X POST -H 'Content-Type: application/json' http://REDMINE_IP_PORT/channels/sales/post_msg.json -d '{"msg": {"event": "customer_arrived"}}'


