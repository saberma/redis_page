require 'active_support/core_ext/class/attribute_accessors'

module ActionController
  module Caching
    module Pages
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods
        def caches_redis_page(*actions)
          options = actions.extract_options!

          after_filter({only: actions}.merge(options)) do |c|
            c.cache_page(response.body, request.path)
          end
        end
      end

      def cache_page(content, path)
        Rails.logger.info "[page cache]caching: #{path}"
        $redis.set(path, content)

        if @model_name
          mark_cache_instance(@model_name, @model_id)
        end
      end

    end
  end
end
