require 'action_controller/caching/redis_pages'

module ActionController
  module Caching
    eager_autoload do
      autoload :RedisPages
    end

    include RedisPages
  end
end

ActionController::Base.send(:include, ActionController::Caching::RedisPages)
ActionController::Base.send(:include, RedisPage::ViewHelpers)
