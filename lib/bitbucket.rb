require 'bitbucket/version'

require 'active_support/dependencies/autoload'

require 'active_support/core_ext/hash'
require 'active_support/configurable'

require 'pry'

require 'bitbucket/api'
require 'bitbucket/api/base_api'
require 'bitbucket/api/repos_api'
require 'bitbucket/api/teams_api'
require 'bitbucket/api/users_api'

require 'active_support/notifications'
ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  $stdout.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
end

module Bitbucket
  extend ActiveSupport::Autoload
  autoload :Client
  autoload :ApiFactory

  class << self
    extend Forwardable
    include ActiveSupport::Configurable

    attr_accessor :api_client

    def_delegators :@api_client, :repos, :teams, :users, :configure

    def new(options = {}, &block)
      @api_client = Bitbucket::Client.new(options, &block)
    end
  end
end
