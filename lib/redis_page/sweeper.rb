require 'redis_page/sweeper_worker'

module RedisPage
  module Sweeper
    extend ActiveSupport::Concern

    included do
      after_save :invalidate_instance_cache

      def invalidate_instance_cache
        $redis.smembers("i:#{self.class.table_name}:#{self.id}").each do |url|
          Rails.logger.info "[page cache]add sweeper job: #{url}"
          SweeperWorker.perform_async(url)
        end
      end
    end
  end
end
