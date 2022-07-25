# redmine_rt (Redmine Real-Time plugin)

This plugin provides:
  - Notification of issue changes (addition, removal, update of journals)
  - API method post_msg to permit to send message to channels
  - WebSocket endpoints to permit to subscribe to channels and send/receive messages thru them.
  

This plugin works with Redmine 4 (https://github.com/redmine/redmine).

(tested with 4.1.1, 4.2.2 and 4.2.7)

It currently doesn't work with Redmine 5.


You must install dependency plugin redmine_base_deface:
```
cd plugins
git clone https://github.com/jbbarth/redmine_base_deface
cd redmine_base_deface 
git checkout 7ffa8fcb1364a0d22d5e219d0374942c946aec8f
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

  Administration -> Settings -> Authentication -> 
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


The plugin adds an API endpoint /channels/CHANNEL_NAME/post_msg.json to permit to send messages to channels. 

Usage:
```
  curl -v -x '' -u YOUR_API_TOKEN:fake -X POST -H 'Content-Type: application/json' http://REDMINE_IP_PORT/channels/sales/post_msg.json -d '{"msg": {"event": "customer_arrived"}}'
```

These messages can be received by apps or redmine pages subscribed to them.

Also, remember to logout and login once after these changes otherwise the redmine_rt features might not work.

Sample usage (thanks to [@leoniscsem](https://github.com/leoniscsem)):

![Sample Usage](../assets/redmine_rt2.gif?raw=true)

There is a companion webextension that adds some extra features (but you need to implement an app to publish messages):

  https://addons.mozilla.org/en-US/firefox/addon/redmine_rt/
  
  https://chrome.google.com/webstore/detail/redminert/mnbpcoaepnlppdfgfkkleekfomlbpjgn


Video demonstration:
https://www.youtube.com/watch?v=XiHFAhs5o5M&feature=youtu.be

UPDATE: the webextension is outdated and the mozilla and google stores will eventually remove it for no compliance with new policies. Consider it unavailable for the time being.


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
