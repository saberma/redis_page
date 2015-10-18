require 'active_support/core_ext/class/attribute_accessors'

module ActionController
  module Caching
    module RedisPages
      INSTANCE_PATH_REGEX = /^\/(\w+)\/(\d+)/
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods

        def caches_redis_page(*actions)
          return unless RedisPage.redis
          options = actions.extract_options!

          before_filter({only: actions}.merge(options)) do |c|
            @page_need_to_cache = true
            if options[:append_country]
              # X-IP-Country 是通过 nginx GeoIP2 module 注入的 header
              @cache_country = (cookies[:country] || request.headers['X-IP-Country']).try(:upcase)
            end
          end

          after_filter({only: actions}.merge(options)) do |c|
            #path = request.path    # fixed: /products/ 地址带了/符号，缓存不生效
            path = URI(request.original_url).path
            path = "#{path}-#{@cache_country}" if @cache_country
            c.cache_redis_page(response.body, path)
            c.record_cached_page
          end
        end
      end

      def cache_redis_page(content, path)
        Rails.logger.info "[page cache]caching: #{path}"
        RedisPage.redis.setex(path, RedisPage.config.ttl || 604800, content)    # 1 周后失效
      end

      def record_cached_page
        path, model_name, model_id = INSTANCE_PATH_REGEX.match(request.path).to_a
        if model_id
          mark_cache_instance(model_name, model_id)
        end
      end

    end
  end
end
