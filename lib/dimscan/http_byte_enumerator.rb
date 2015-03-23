require 'uri'
require 'net/http'

module Dimscan
  # A utility class for enumerating over the bytes of a http response body
  class HTTPByteEnumerator
    @connections = {}
    class << self
      def open_connection(host, port, ssl)
        @connections[host] ||= {}
        @connections[host][port] ||= {}
        @connections[host][port][ssl] ||= Net::HTTP.start(
          host, port, use_ssl: ssl
        )
      end

      def close_connections
        @connections.values.each do |ports|
          ports.values.each do |connections|
            connections.values.each(&:finish)
          end
        end
      end
    end

    def initialize(url)
      @uri = URI(url)
      fail ArgumentError, 'invalid scheme' unless @uri.scheme =~ /^https?$/
    end

    def each(&block)
      return to_enum(__callee__) unless block_given?
      request = Net::HTTP::Get.new(@uri)
      http = self.class.open_connection(
        @uri.host, @uri.port, @uri.scheme == 'https'
      )
      http.request(request) do |response|
        fail response.body if error?(response)
        enumerate_response(response, &block)
      end
    end

    protected

    def error?(response)
      [Net::HTTPError, Net::HTTPClientError].any? do |error|
        response.is_a?(error)
      end
    end

    def enumerate_response(response, &block)
      response.read_body do |chunk|
        chunk.each_byte(&block)
      end
    end
  end
end
