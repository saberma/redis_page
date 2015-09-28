require 'redis_page/view_helpers'

module RedisPage
  class Railtie < Rails::Railtie
    initializer "redis_page" do
      ActiveSupport.on_load(:action_controller) do
        require 'action_controller/redis_page_caching'
      end
    end

    initializer "redis_page.activerecord" do
      ActiveSupport.on_load(:active_record) do
        require 'redis_page/sweeper'
      end
    end

    initializer "redis_page.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
