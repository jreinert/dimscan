require 'uri'
require 'net/http'
require 'spec_helper'
require 'dimscan/http_byte_enumerator'

# HTTPByteEnumerator specs
module Dimscan
  describe HTTPByteEnumerator do
    describe '.new' do
      it 'requires a http/https url' do
        expect { HTTPByteEnumerator.new }.to raise_error(ArgumentError)
        expect { HTTPByteEnumerator.new(1) }.to raise_error(ArgumentError)
        expect { HTTPByteEnumerator.new('ftp://not/http') }.to(
          raise_error(ArgumentError)
        )
        HTTPByteEnumerator.new('http://valid/http/url')
        HTTPByteEnumerator.new('https://valid/https/url')
      end
    end
  end
end
