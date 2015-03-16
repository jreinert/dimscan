require 'spec_helper'
require 'support/scanner_spec'
require 'dimscan/png_scanner'

# "JPEG example JPG RIP 100" by Original uploader was Toytoy at en.wikipedia -
# Transferred from en.wikipedia; transferred to Commons by User:Masur using
# CommonsHelper.. Licensed under CC BY-SA 3.0 via Wikimedia Commons -
# https://commons.wikimedia.org/wiki/File:JPEG_example_JPG_RIP_100.jpg#/media/File:JPEG_example_JPG_RIP_100.jpg

# Specs for PNGScanner
module Dimscan
  describe PNGScanner do
    it_behaves_like(
      'a scanner',
      'https://raw.githubusercontent.com/jreinert/dimscan/master/' \
        'spec/fixtures/313x234.png',
      'spec/fixtures/313x234.png',
      'spec/fixtures/32x32.png'
    )
  end
end
