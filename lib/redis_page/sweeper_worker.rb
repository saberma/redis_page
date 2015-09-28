module RedisPage
  class SweeperWorker
    include Sidekiq::Worker

    def perform(url, country=nil)
      uri = URI(url)
      uri.port = 8081

      auth = { username: "cache", password: "ewHN84JZLyRurX" }
      options = { basic_auth: auth }
      options[:cookies] = { country: country } if country

      Rails.logger.info "[page cache]sweeper fetching: #{url}, country: #{country}"
      response = HTTParty.get(uri, options)
      Rails.logger.debug "[page cache]sweeper response: #{response.body}"
    end
  end
end
