# frozen_string_literal: true

require "forwardable"
require "libhoney"
require "honeycomb/beeline/version"
require "honeycomb/client"
require "honeycomb/trace"

# main module
module Honeycomb
  INTEGRATIONS = %i[
    active_support
    faraday
    rack
    rails
    rake
    sequel
    sinatra
  ].freeze

  class << self
    extend Forwardable
    attr_reader :client

    def_delegators :@client, :start_span, :add_field, :add_field_to_trace

    def configure
      Configuration.new.tap do |config|
        yield config
        @client = Honeycomb::Client.new(configuration: config)
      end

      @client
    end

    def load_integrations
      INTEGRATIONS.each do |integration|
        begin
          require "honeycomb/integrations/#{integration}"
        rescue LoadError
        end
      end
    end
  end
end

Honeycomb.load_integrations unless ENV["HONEYCOMB_DISABLE_AUTOCONFIGURE"]
