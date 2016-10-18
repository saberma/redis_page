module RedisPage
  module Writter
    class Base

      def write(content, path, options = {})
        key  = path
        text = "[page cache]caching: #{path}"
        if namespace = options[:namespace]
          key  = "#{namespace}:#{key}"
          text = "#{text} in #{namespace}"
        end
        Rails.logger.info text
        # RedisPage.cache_page_redis.setex(key, RedisPage.config.ttl || 604800, content)    # 1 周后失效
        # 对于某个原本带有生存时间（TTL）的键来说， 当 SET 命令成功在这个键上执行时， 这个键原有的 TTL 将被清除。
        RedisPage.cache_page_redis.set(key, content)    # 永不失效
      end

    end
  end
end
