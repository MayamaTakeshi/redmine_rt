# redmine_rt

Requirement:
  redmine_base_deface >= '0.0.1'

This works with Redmine 4 (using ActionCable) and 3 (using websocket-rails).

Install it following usual plugin installation procedure.
Then:


***For Redmine 4***:
Add create file in redmine/app/cable.yml with the following content:
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


Start server doing:
```
bundle exec rails server thin  -e production -b 0.0.0.0
```


Currently we just send notification of events (we don't send html fragments to clients) and this causes the client to update the page (making ajax calls if necessary).


I recommend to use:
  "My account" > Preferences > "Display comments" = "In reverse chronological order"
as this will make "quick_notes" to be put above history section that I think looks better than having it below it.
