module RedisPage
  class SweeperWorker
    include Sidekiq::Worker

    def perform(url)
      uri = URI(url)
      uri.port = 8081

      auth = { username: "cache", password: "ewHN84JZLyRurX" }

      Rails.logger.info "[page cache sweeper]fetching: #{url}"
      response = HTTParty.get(uri, basic_auth: auth)
      Rails.logger.debug "[page cache sweeper]response: #{response.body}"
    end
  end
end
