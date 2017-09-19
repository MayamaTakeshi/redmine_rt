
require_dependency 'redmine_rt/channels/application_cable/connection'
require_dependency 'redmine_rt/channels/application_cable/channel'
require_dependency 'redmine_rt/channels/messages_channel'

require 'redmine'

ActiveSupport::Reloader.to_prepare do 
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)  
  # and registering multiple callbacks

  unless Issue.included_modules.include? RedmineRt::IssuePatch
    Issue.send(:include, RedmineRt::IssuePatch)
  end

  unless Journal.included_modules.include? RedmineRt::JournalPatch
    Journal.send(:include, RedmineRt::JournalPatch)
  end

  unless IssuesController.included_modules.include? RedmineRt::IssuesControllerPatch
    IssuesController.send(:include, RedmineRt::IssuesControllerPatch)
  end

  unless JournalsController.included_modules.include? RedmineRt::JournalsControllerPatch
    JournalsController.send(:include, RedmineRt::JournalsControllerPatch)
  end
end

Redmine::Plugin.register :redmine_rt do
  name 'Redmine Rt plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  #requires_redmine :version_or_higher => '4.0.0'
  #requires_redmine :version => '3.4.2.devel' # Redmine currently doesn't accept this
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
end
