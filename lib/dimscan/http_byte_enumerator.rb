require 'uri'
require 'net/http'

module Dimscan
  # A utility class for enumerating over the bytes of a http response body
  class HTTPByteEnumerator
    def initialize(url)
      @uri = URI(url)
      fail ArgumentError, 'invalid scheme' unless @uri.scheme =~ /^https?$/
    end

    def each(&block)
      return to_enum(__callee__) unless block_given?
      request = Net::HTTP::Get.new(@uri)
      Net::HTTP.start(
        @uri.host, @uri.port, use_ssl: @uri.scheme == 'https'
      ) do |http|
        http.request(request) do |response|
          fail response.body if error?(response)
          enumerate_response(response, &block)
        end
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
