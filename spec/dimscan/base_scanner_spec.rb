require 'dimscan/base_scanner'

# BaseScanner specs
module Dimscan
  describe BaseScanner do
    describe '.new' do
      it 'raise an AbstractError' do
        expect { BaseScanner.new('http://valid/url') }.to raise_error(
          AbstractError
        )
      end
    end

    describe '#scan_dimensions' do
      let(:scanner) do
        Class.new(BaseScanner).new('http://localhost:5959/image.jpeg')
      end

      it 'raise an AbstractError' do
        expect { scanner.scan_dimensions }.to raise_error(AbstractError)
      end

      it 'calls #scan' do
        allow(scanner).to receive(:scan)
        scanner.scan_dimensions rescue false
        expect(scanner).to have_received(:scan)
      end
    end
  end
end
