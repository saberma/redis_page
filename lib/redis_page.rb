require 'redis_page/railtie'
require 'redis_page/writter/base'

module RedisPage
  class Config
    attr_accessor :sweeper, :redis, :ttl
    attr_accessor :cache_page_redis, :cache_relation_redis
    attr_accessor :compress_method
    attr_accessor :page_content_writter
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

  def self.cache_page_redis
    config.cache_page_redis || config.redis
  end

  def self.cache_relation_redis
    config.cache_relation_redis || config.redis
  end

  # :deflate or nil
  def self.compress_method
    [:deflate, :gzip].include?(config.compress_method) ? config.compress_method : nil
  end

  def self.page_content_writter
    config.page_content_writter || RedisPage::Writter::Base.new
  end

  def self.sweeper
    config.sweeper
  end
end
