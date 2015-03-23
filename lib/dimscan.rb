require 'dimscan/version'
require 'dimscan/jpeg_scanner'
require 'dimscan/png_scanner'
require 'dimscan/http_byte_enumerator'

module Dimscan
  class << self
    def close_connections
      HTTPByteEnumerator.close_connections
    end
  end
end
