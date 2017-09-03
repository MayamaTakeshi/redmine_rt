
require_dependency 'redmine_rt_hook'

require 'redmine'

ActiveSupport::Reloader.to_prepare do 
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)  
  # and registering multiple callbacks
  unless Issue.included_modules.include? RedmineRt::IssuePatch
    Issue.send(:include, RedmineRt::IssuePatch)
  end
end

Redmine::Plugin.register :redmine_rt do
  name 'Redmine Rt plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
