require 'uri'
require 'dimscan/http_byte_enumerator'
require 'mini_magick'
require 'abstractize'

module Dimscan
  # The abstract base class
  class BaseScanner
    include Abstractize

    def initialize(url)
      @bytes = HTTPByteEnumerator.new(url)
      @fallback_file = `mktemp`.chomp
    end

    def scan_dimensions
      dimensions = nil
      File.open(@fallback_file, 'wb') do |file|
        dimensions = scan(@bytes.each) { |b| file.write(b) }
      end
      width, height = (
        dimensions || MiniMagick::Image.new(@fallback_file).dimensions
      )

      File.delete(@fallback_file)
      { width: width, height: height }
    end

    protected

    def scan(_bytes)
      fail AbstractError, 'not implemented'
    end
  end
end
