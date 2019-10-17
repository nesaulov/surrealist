# frozen_string_literal: true

RSpec.describe Surrealist::Result do
  describe Surrealist::Result::Success do
    let(:result) { described_class::INSTANCE }

    it 'is successful' do
      expect(result.success?).to eq(true)
    end

    it 'runs a block passed to #success?' do
      expect(result.success? { 'kek' }).to eq('kek')
    end

    it 'is not a failure' do
      expect(result.failure?).to eq(false)
    end

    it 'does not run a block passed to #failure?' do
      expect(result.failure? { raise }).to eq(false)
    end
  end

  describe Surrealist::Result::Failure do
    let(:result) { described_class.new('some error') }

    it 'is unsuccessful' do
      expect(result.success?).to eq(false)
    end

    it 'does not run a block passed to #success?' do
      expect(result.success? { raise }).to eq(false)
    end

    it 'is a failure' do
      expect(result.failure?).to eq(true)
    end

    it 'runs a block passed to #failure?' do
      expect(result.failure? { 'pek' }).to eq('pek')
    end
  end
end
