require 'uri'
require 'oauth'
require 'json'

module ContextIO
  module API
    @@version = '2.0'
    @@key = nil
    @@secret = nil
    @@base_url = 'https://api.context.io'

    def self.version
      @@version
    end

    def self.version=(version)
      @@version = version
    end

    def self.key
      @@key
    end

    def self.key=(key)
      @@key = key
    end

    def self.secret
      @@secret
    end

    def self.secret=(secret)
      @@secret = secret
    end

    def self.base_url
      @@base_url
    end

    def self.base_url=(base_url)
      @@base_url = base_url
    end

    def self.consumer
      unless @@consumer || (key && secret)
        raise ContextIO::ConfigurationError, 'You must provide a key and a secret. Assign them with "ContextIO::API.key = <KEY>" and "ContextIO::API.secret = <SECRET>".'
      end

      @@consumer ||= OAuth::Consumer.new(key, secret, site: base_url)
    end

    def self.token
      @@token ||= OAuth::AccessToken.new(consumer)
    end

    def self.request(method, command, params = {})
      JSON.parse(token.send(method, path(command, params), 'Accept' => 'application/json'))
    end

    private

    def self.path(command, params = {})
      path = "/#{ContextIO::API.version}/#{command}"

      unless params.empty?
        path << "?#{paramaterize(params)}"
      end

      path
    end

    def self.paramaterize(params)
      params = params.inject({}) do |memo, (k, v)|
        memo[k] = Array(v).join(',')

        memo
      end

      URI.encode_www_form(params)
    end
  end
end