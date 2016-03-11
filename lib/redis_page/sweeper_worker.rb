require "sidekiq"

module RedisPage
  class SweeperWorker
    include Sidekiq::Worker

    # 相同 url 和 country 的缓存清理请求，在2分钟内只能执行一次
    sidekiq_options queue: :redis_page, retry: false, unique: :until_timeout, unique_expiration: 2 * 60

    def perform(url, country=nil)
      uri = URI(url)
      uri.port = RedisPage.sweeper[:port]
      uri.scheme = 'http'
      uri.query  = uri.fragment = nil    # 去掉 query string 等

      auth = { username: RedisPage.sweeper[:username], password: RedisPage.sweeper[:password] }
      options = { basic_auth: auth }
      options[:cookies] = { country: country } if country

      Rails.logger.info "[page cache]sweeper fetching: #{uri}, country: #{country}"
      response = HTTParty.get(uri.to_s, options)
      Rails.logger.debug "[page cache]sweeper response: #{response.body}"
    end
  end
end
