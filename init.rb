require 'redmine'

def prepare() 
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

if Rails::VERSION::MAJOR < 5
  raise "Only Rails 5 and over are supported"
end

Rails.application.config.action_cable.disable_request_forgery_protection = true

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  prepare()
else
  #require_dependency 'redmine_rt/channels/application_cable/connection'
  #require_dependency 'redmine_rt/channels/application_cable/channel'
  #require_dependency 'redmine_rt/channels/channel'
  require_dependency 'redmine_rt/broadcaster'
  require_dependency 'issue'
  #require_dependency 'redmine_rt/channels_controller'

  ActiveSupport::Reloader.to_prepare do
    prepare()
  end
end

Rails.configuration.to_prepare do
  Redmine::Plugin.find(:redmine_rt).assets_paths << File.expand_path('assets', __dir__)
end

Redmine::Plugin.register :redmine_rt do
  name 'Redmine Rt plugin'
  author 'MayamaTakeshi'
  description 'Redmine plugin for realtime features'
  version '1.1.1'
  url 'https://github.com/MayamaTakeshi/redmine_rt'
  author_url 'https://github.com/MayamaTakeshi'

  #requires_redmine :version_or_higher => '4.0.0'
  #requires_redmine :version => '3.4.2.devel' # Redmine currently doesn't accept this
  #requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'

  menu :top_menu, :realtime, {controller: 'realtime', action: 'index'}, caption: 'Realtime'
end
