require 'redis_page/railtie'

module RedisPage
  class Config
    attr_accessor :sweeper, :redis, :ttl
  end

  def self.config
    @@config ||= Config.new
  end

  def self.configure
    yield self.config
  end

  def self.redis
    config.redis
  end

  def self.sweeper
    config.sweeper
  end
end
