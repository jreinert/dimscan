require 'dimscan/base_scanner'

module Dimscan
  # Scans dimensions from a JPEG image
  class JPEGScanner < BaseScanner
    SOF0 = [0xFF, 0xC0, 0x00, 0x11, 0x08]

    protected

    def scan(bytes)
      # Dimensions are in bytes 4-8 after SOF0
      last_slice = nil
      bytes.each_cons(SOF0.size + 4) do |slice|
        yield slice.first.chr
        last_slice = slice
        if slice.first(SOF0.size) == SOF0
          return extract_dimensions(slice.last(4))
        end
      end
      yield last_slice[1..-1].map(&:chr).join
      nil
    end

    def extract_dimensions(bytes)
      # height is before width in jpeg header
      byte_string = bytes.map(&:chr).join
      byte_string.unpack('nn').reverse
    end
  end
end
