RSpec.shared_examples 'a scanner' do |uri, file_with_dims, file_without_dims|
  let(:scanner_local_with_dims) do
    stub_const('Dimscan::HTTPByteEnumerator', stubbed_enumerator_with_dims)
    described_class.new(uri)
  end

  let(:scanner_local_without_dims) do
    stub_const('Dimscan::HTTPByteEnumerator', stubbed_enumerator_without_dims)
    described_class.new(uri)
  end

  let(:scanner_hosted) do
    described_class.new(uri)
  end

  let(:stubbed_enumerator_with_dims) do
    Class.new do
      def initialize(_)
      end

      define_method(:each) do |&block|
        return to_enum(__callee__) unless block
        File.open(file_with_dims, 'rb') do |file|
          file.each_byte(&block)
        end
      end
    end
  end

  let(:stubbed_enumerator_without_dims) do
    Class.new do
      def initialize(_)
      end

      define_method(:each) do |&block|
        return to_enum(__callee__) unless block
        File.open(file_without_dims, 'rb') do |file|
          file.each_byte(&block)
        end
      end
    end
  end

  describe '#scan_dimensions' do
    it 'returns correct dimensions for a local image' do
      expect(scanner_local_with_dims.scan_dimensions).to eq(
        width: 313, height: 234
      )
    end

    it 'returns correct dimensions for images without dimensions in header' do
      expect(scanner_local_without_dims.scan_dimensions).to eq(
        width: 32, height: 32
      )
    end

    it 'returns correct dimensions for a hosted jpeg image' do
      expect(scanner_hosted.scan_dimensions).to eq(width: 313, height: 234)
    end
  end
end
