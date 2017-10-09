require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module RedmineApp
  class Application < Rails::Application

    config.middleware.delete Rack::Lock
  end
end


