# redmine_rt

This works only on Rails 5.2.1 or above (use redmine head)

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
