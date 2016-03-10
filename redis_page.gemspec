# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_page/version'

Gem::Specification.new do |spec|
  spec.name          = "redis_page"
  spec.version       = RedisPage::VERSION
  spec.authors       = ["saberma"]
  spec.email         = ["mahb45@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{use redis to cache your rails page.}
  spec.description   = %q{use redis to cache your rails page.}
  spec.homepage      = "https://github.com/saberma/redis_page"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.0.9"
  spec.add_dependency "actionpack", "~> 4.0.9"
  spec.add_dependency "sidekiq", "~> 3.2.6"
  spec.add_dependency "sidekiq-unique-jobs", "~> 4.0.17"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
