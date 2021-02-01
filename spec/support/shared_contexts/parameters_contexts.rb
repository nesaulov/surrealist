# frozen_string_literal: true

require_relative '../parameters'

shared_context 'error is raised for invalid params: instance' do
  INVALID_PARAMS.each do |params|
    it "fails with #{params}" do
      expect { instance.surrealize(**params) }.to raise_error(ArgumentError)
    end
  end
end

shared_context 'error is not raised for valid params: instance' do
  VALID_PARAMS.each do |params|
    it "works with #{params}" do
      expect { instance.surrealize(**params) }.not_to raise_error
      expect(instance.surrealize(**params)).to be_a(String)
    end
  end
end

shared_context 'error is raised for invalid params: collection' do
  INVALID_PARAMS.each do |params|
    it "fails with #{params}" do
      expect { Surrealist.surrealize_collection(collection, **params) }
        .to raise_error(ArgumentError)
    end
  end
end

shared_context 'error is not raised for valid params: collection' do
  VALID_PARAMS.each do |params|
    it "works with #{params}" do
      expect { Surrealist.surrealize_collection(collection, **params) }.not_to raise_error
      expect(Surrealist.surrealize_collection(collection, **params)).to be_a(String)
    end
  end
end
