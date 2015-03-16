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

    describe '.each' do
      let(:uri) { URI('http://valid/uri') }
      let(:enumerator) { HTTPByteEnumerator.new(uri) }
      let(:first_response_chunk) do
        response_chunk = double('response_chunk')
        allow(response_chunk).to receive(:each_byte).and_yield(1).and_yield(2)
        response_chunk
      end
      let(:second_response_chunk) do
        response_chunk = double('response_chunk')
        allow(response_chunk).to receive(:each_byte).and_yield(3).and_yield(4)
        response_chunk
      end
      let(:response_stub) do
        response = double('response')
        allow(response).to receive(:read_body).and_yield(
          first_response_chunk
        ).and_yield(
          second_response_chunk
        )
        response
      end
      let(:net_http_get_stub) { double('Net::HTTP::Get', new: :get_request) }
      let(:http_stub) do
        result = double('http')
        allow(result).to receive(:request).with(:get_request).and_yield(
          response_stub
        )
        result
      end
      let(:net_http_stub) do
        Module.new do
          def start(*)
            yield http_stub
          end
          module_function :start
        end
      end

      before(:each) do
        stub_const('Net::HTTP', net_http_stub)
        stub_const('Net::HTTP::Get', net_http_get_stub)
        allow(Net::HTTP).to receive(:start).and_yield(http_stub)
      end

      it 'opens a HTTP connection' do
        enumerator.each { |_| }
        expect(Net::HTTP).to have_received(:start).with(
          uri.host, uri.port, use_ssl: false
        )
      end

      it 'sends a get request to the given url' do
        expect(net_http_get_stub).to receive(:new).with(uri)
        enumerator.each { |_| }
        expect(http_stub).to have_received(:request).with(:get_request)
      end

      it 'yields a byte at a time' do
        expect { |b| enumerator.each(&b) }.to yield_successive_args(1, 2, 3, 4)
      end

      it 'returns an enumerator that returns the bytes if no block is given' do
        enum = enumerator.each
        expect(enum).to be_an(Enumerator)
        expect(enum.next).to eq(1)
        expect(enum.next).to eq(2)
        expect(enum.next).to eq(3)
        expect(enum.next).to eq(4)
      end
    end
  end
end
