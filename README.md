# redmine_rt (Redmine Real-Time plugin)

## Overview 
This plugin provides:
  - Notification of issue changes (addition, removal, update of journals).
  - API method post_msg to permit to send message to channels
  - WebSocket endpoints to permit to subscribe to channels and send/receive messages thru them.
  - a text field to permit to quickly insert new comments ("Notes box") on an issue without having to reload the current issue page.

It uses Ruby on Rails Action Cable to permit realtime notification of events (and for this, you need to have a redis-server installed somewhere).

This plugin works with Redmine 4 and 5 (https://github.com/redmine/redmine).

(tested with 4.1.1, 4.2.2, 4.2.7, 4.2.9, 5.0.0, 5.0.2, 5.0.4 and 5.0.5)

## Installation:

```
cd REDMINE_ROOT_FOLDER/plugins
git clone https://github.com/MayamaTakeshi/redmine_rt
cd ..
bundle install
```

Then you need to setup your redmine server:

  Administration -> Settings -> Authentication -> 
    "Autologin" must be enabled.

  Administration -> Settings -> API 
    "Enable REST web service" must be ON.


Then install redis-server. In debian/ubuntu just do:
```
apt install redis-server
```

Then create file redmine/config/cable.yml with the following content (adjust the url if you are running redis-server on a separate machine):
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

For Redmine 4:
```
bundle exec rails server puma -e production -b 0.0.0.0
```

For Redmine 5:
```
bundle exec rails server -e production -b 0.0.0.0
```

Obs: do not use webrick as it will not work properly with WebSocket/ActionCable (you will see something like 'NotImplementedError (only partial hijack is supported.)')


Regarding Redmine configuration, I recommend to use:
  "My account" > Preferences > "Display comments" = "In reverse chronological order"
as this will make the Notes box to be put above history section that I think looks better than having it below it when update of notes is done.


The plugin adds an API endpoint /channels/CHANNEL_NAME/post_msg.json to permit to send messages to channels. 

Usage:
```
  curl -v -x '' -u YOUR_API_TOKEN:fake -X POST -H 'Content-Type: application/json' http://REDMINE_IP_PORT/channels/sales/post_msg.json -d '{"msg": {"event": "customer_arrived"}}'
```

These messages can be received by apps or redmine pages subscribed to them.

Also, remember to logout and login once after these changes otherwise the redmine_rt features might not work.

Sample usage (thanks to [@leoniscsem](https://github.com/leoniscsem)):

![Sample Usage](../assets/redmine_rt2.gif?raw=true)

There is a companion webextension that adds some extra features like integration with PBXes (but you need to implement an app to publish messages):

  https://addons.mozilla.org/en-US/firefox/addon/redmine_rt/
  
  https://chrome.google.com/webstore/detail/redminert/mnbpcoaepnlppdfgfkkleekfomlbpjgn


Video demonstration:
https://www.youtube.com/watch?v=XiHFAhs5o5M&feature=youtu.be

UPDATE: the webextension is outdated and the mozilla and google stores will eventually remove it for no compliance with new policies. Consider it unavailable for the time being.

As an alternative, we added a new page "realtime" that if left open, can receive requests from PBXs to open issue tabs when calls are answered.
Video demonstration:
https://www.youtube.com/watch?v=1O_XvIC5yhE


In case you use redmine behind a proxy like nginx you will need to properly setup the proxy to handle websocket connections.
Add something like this before your location block for redmine:
```
        location = /redmine/cable {
            proxy_set_header        Host            $host;
            proxy_set_header        X-Real-IP       $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        Upgrade         $http_upgrade;
            proxy_set_header        Connection      $connection_upgrade;
            proxy_http_version 1.1;
            proxy_read_timeout 120;

            proxy_pass http://YOUR_REDMINE_SERVER/redmine/cable;
        }
```

Here is a full nginx.conf sample contributed by [@leoniscsem](https://github.com/leoniscsem):
```
upstream puma_redmine {
   server unix:/path/to/redmine/tmp/puma.sock fail_timeout=0;
   }

server {
  server_name redmine.domain.tld;
  listen 80;
  # Strict Transport Security
  #add_header Strict-Transport-Security max-age=2592000;
  return 301 https://$server_name:443$request_uri;
  #rewrite ^/.*$ https://$host$request_uri? permanent;
  }

server {
   server_name redmine.domain.tld;
   listen 443 ssl http2;
   root /path/to/redmine/public;

   ssl_certificate /etc/letsencrypt/live/domain.tld/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/domain.tld/privkey.pem;

   access_log /var/log/nginx/redmine.access.log;
   error_log /var/log/nginx/redmine.error.log;

   location / {
     try_files $uri $uri/index.html @app;
   }

   location = /cable {
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header Upgrade $http_upgrade;
     proxy_set_header Connection $connection_upgrade;
     proxy_http_version 1.1;
     proxy_read_timeout 120;
     proxy_pass http://puma_redmine/cable;
   }


   location ^~ /assets/ {
     gzip_static on;
     expires max;
     add_header Cache-Control public; 
     proxy_set_header X-Forwarded-For $remote_addr;
   }

   location @app {
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header Host $http_host;
     proxy_redirect off;
     proxy_set_header X-Forwarded-Proto $scheme;

     proxy_set_header X-Real-IP $remote_addr;
     proxy_read_timeout 300;

     proxy_pass http://puma_redmine;
    }
  }
```
## Integration with redmine_issue_dynamic_edit
Redmine_rt integrates nicely with 
  https://github.com/Ilogeek/redmine_issue_dynamic_edit

Video:
  https://www.youtube.com/watch?v=XY5YeteGRBk
  
However, there are changes required in redmine_issue_dynamic_edit for this to work.

So until our changes are accepted, you should use our specific branch:
```
cd plugins
git clone -b integration_with_redmine_rt https://github.com/MayamaTakeshi/redmine_issue_dynamic_edit
```
