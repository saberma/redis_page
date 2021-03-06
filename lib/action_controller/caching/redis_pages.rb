require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/gzip'
require 'zlib'

module ActionController
  module Caching
    module RedisPages
      INSTANCE_PATH_REGEX = /^\/(\w+)\/(\d+)/
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods

        def caches_redis_page(*actions)
          return unless (RedisPage.cache_relation_redis && RedisPage.cache_page_redis)
          options = actions.extract_options!

          before_filter({only: actions}.merge(options)) do |c|
            @page_need_to_cache = true
            if options[:append_country]
              # X-IP-Country 是通过 nginx GeoIP2 module 注入的 header
              @cache_country = (cookies[:country] || request.headers['X-IP-Country']).try(:upcase)
            end
          end

          after_filter({only: actions}.merge(options)) do |c|
            path = [request.path, @cache_country, RedisPage.compress_method].compact.join('-')
            c.cache_redis_page(compress_content(response.body), path, options)
            c.record_cached_page
          end
        end
      end

      def compress_content(content)
        case RedisPage.compress_method
        when :deflate
          Zlib::Deflate.deflate(content)
        when :gzip
          ActiveSupport::Gzip.compress(content)
        else
          content
        end
      end

      def cache_redis_page(content, path, options = {})
        RedisPage.page_content_writter.write(content, path, options)
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
