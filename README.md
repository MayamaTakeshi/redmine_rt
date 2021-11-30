# redmine_rt (Redmine Real-Time plugin)

This plugin provides:
  - Notification of issue changes (addition, removal, update of journals)
  - API method post_msg to permit to send message to channels
  - WebSocket endpoints to permit to subscribe to channels and send/receive messages thru them.
  

This plugin works with Redmine 4 and above (https://github.com/redmine/redmine).

(tested with 4.1.1 and 4.2.2)


You must install dependency plugin redmine_base_deface:
```
cd plugins
git clone https://github.com/jbbarth/redmine_base_deface
```

Install redmine_rt following usual plugin installation procedure:
```
cd plugins
git clone https://github.com/MayamaTakeshi/redmine_rt
```

Then:
```
cd ..
bundle install
```

Obs: if the above fails while installing nokogiri or puma, try to install them using gem:
```
gem install nokogiri
gem install puma
```

Then you need to setup your redmine server:

  Administration -> Authentication -> 
    "Autologin" must be enabled.

  Administration -> Settings -> API 
    "Enable REST web service" must be ON.



Then install redis-server.
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
Currently we just send notification of events (we don't send html fragments to clients) and this causes the client to update the page (making ajax calls if necessary).


I recommend to use:
  "My account" > Preferences > "Display comments" = "In reverse chronological order"
as this will make "quick_notes" to be put above history section that I think looks better than having it below it when update of notes is done.


The plugin adds an API endpoint /channels/CHANNEL_NAME/post_msg.json to permit to send messages to channels. Usage:
  curl -v -x '' -u YOUR_API_TOKEN:fake -X POST -H 'Content-Type: application/json' http://REDMINE_IP_PORT/channels/sales/post_msg.json -d '{"msg": {"event": "customer_arrived"}}'



There is a companion webextension that adds some extra features (but you need to implement an app to publish messages):

  https://addons.mozilla.org/en-US/firefox/addon/redmine_rt/
  
  https://chrome.google.com/webstore/detail/redminert/mnbpcoaepnlppdfgfkkleekfomlbpjgn


Video demonstration:
https://www.youtube.com/watch?v=XiHFAhs5o5M&feature=youtu.be

UPDATE: the webextension is outdated and the mozilla and goggle stores will eventually remove it for no compliance with new policies. Consider it unavailable for the time being.

