require 'uri'
require 'net/http'
require 'spec_helper'
require 'dimscan/http_byte_enumerator'
require 'pry'

# HTTPByteEnumerator specs
module Dimscan
  describe HTTPByteEnumerator do
    let(:response_stub) { double('response') }
    let(:http_stub) do
      result = double('http')
      allow(result).to receive(:request).with(:get_request).and_yield(
        response_stub
      )
      result
    end

    let(:net_http_stub) do
      http_stub = self.http_stub
      Module.new do
        define_method(:start) do |*|
          http_stub
        end
        module_function :start
      end
    end

    let(:net_http_get_stub) { double('Net::HTTP::Get', new: :get_request) }

    before(:each) do
      stub_const('Net::HTTP', net_http_stub)
      stub_const('Net::HTTP::Get', net_http_get_stub)
    end

    describe '.open_connection' do
      it 'requires host, port and use_ssl arguments' do
        expect { HTTPByteEnumerator.open_connection }.to raise_error(
          ArgumentError
        )
        expect { HTTPByteEnumerator.open_connection('foo') }.to raise_error(
          ArgumentError
        )
        expect do
          HTTPByteEnumerator.open_connection('foo', 'bar')
        end.to raise_error(ArgumentError)
        HTTPByteEnumerator.open_connection('foo', 'bar', false)
      end

      it 'opens a new http connection' do
        expect(net_http_stub).to receive(:start).with(
          'https://valid/https/url',
          443,
          use_ssl: true
        )
        HTTPByteEnumerator.open_connection(
          'https://valid/https/url',
          443,
          true
        )
      end

      it 'reuses old connections' do
        expect(net_http_stub).to receive(:start).once.and_return(:baz)
        HTTPByteEnumerator.open_connection('foo', 'bar', 'baz')
        result = HTTPByteEnumerator.open_connection('foo', 'bar', 'baz')
        expect(result).to eq(:baz)
      end
    end

    describe '.close_connections' do
      it 'calls finish on all connections' do
        connection = double('http')
        other_connection = double('http')
        HTTPByteEnumerator.instance_variable_set(
          :@connections,
          foo: {
            bar: {
              baz: connection
            },
            foobar: {
              foo: other_connection
            }
          }
        )
        expect(connection).to receive(:finish)
        expect(other_connection).to receive(:finish)
        HTTPByteEnumerator.close_connections
      end
    end

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

      it 'opens a HTTP connection' do
        expect(HTTPByteEnumerator).to receive(:open_connection).with(
          uri.host, uri.port,  false
        ).and_return(http_stub)
        enumerator.each { |_| }
      end

      it 'sends a get request to the given url' do
        expect(net_http_get_stub).to receive(:new).with(uri)
        enumerator.each { |_| }
        expect(http_stub).to have_received(:request).with(:get_request)
      end

      it 'yields a byte at a time' do
        HTTPByteEnumerator.instance_variable_set(:@connections, {})
        expect { |b| enumerator.each(&b) }.to yield_successive_args(1, 2, 3, 4)
      end

      it 'returns an enumerator that returns the bytes if no block is given' do
        HTTPByteEnumerator.instance_variable_set(:@connections, {})
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
