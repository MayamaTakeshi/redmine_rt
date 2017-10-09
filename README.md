# redmine_rt

This works only on Rails 5.2.1 or above (use redmine head)

Requirement:
 redmine_base_deface >= '0.0.1'

Install this following usual plugin installation procedure.
Then add create file in redmine/app/cable.yml with the following content:
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

Currently we just send notification of events (we don't send html fragments to clients) and this causes the client to update the page (making ajax calls if necessary).
We might eventually change the code to push html fragments but considering that we might want to permit for this plugin to be used with previous redmine versions where we will not have tight integration between WebSocket server and redmine, maybe it is better to keep it this way.


I recommend to use:
  "My account" > Preferences > "Display comments" = "In reverse chronological order"
as this will make "quick_notes" to be put above history section that I think looks better than having it below it.
