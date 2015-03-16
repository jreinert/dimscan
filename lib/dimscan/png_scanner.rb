require 'dimscan/base_scanner'

module Dimscan
  # Scans dimensions from a PNG image
  class PNGScanner < BaseScanner
    IHDR = [0x49, 0x48, 0x44, 0x52]

    protected

    def scan(bytes)
      # Dimensions are in 8 bytes after IHDR
      last_slice = nil
      bytes.each_cons(IHDR.size + 8) do |slice|
        yield slice.first.chr
        last_slice = slice
        if slice.first(IHDR.size) == IHDR
          return extract_dimensions(slice.last(8))
        end
      end
      yield last_slice[1..-1].map(&:chr).join
      nil
    end

    def extract_dimensions(bytes)
      byte_string = bytes.map(&:chr).join
      byte_string.unpack('NN')
    end
  end
end
