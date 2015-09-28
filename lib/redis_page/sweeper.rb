require 'redis_page/sweeper_worker'

module RedisPage
  module Sweeper
    extend ActiveSupport::Concern

    included do
      after_save :invalidate_instance_cache

      def invalidate_instance_cache
        $redis.smembers("i:#{self.class.table_name}:#{self.id}").each do |info|
          info = JSON.parse(info)
          Rails.logger.info "[page cache]add sweeper job: #{info['url']}-#{info['country']}"
          SweeperWorker.perform_async(info['url'], info['country'])
        end
      end
    end
  end
end
