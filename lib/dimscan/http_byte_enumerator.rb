require 'uri'
require 'net/http/persistent'

module Dimscan
  # A utility class for enumerating over the bytes of a http response body
  class HTTPByteEnumerator

    class << self
      def http
        @http ||= Net::HTTP::Persistent.new('dimscan')
      end
    end

    def initialize(url)
      @uri = URI(url)
      fail ArgumentError, 'invalid scheme' unless @uri.scheme =~ /^https?$/
    end

    def each(&block)
      return to_enum(__callee__) unless block_given?
      self.class.http.request(@uri) do |response|
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
