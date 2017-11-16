# frozen_string_literal: true

require_relative 'models'

RSpec.describe 'Sequel integration' do
  describe 'instances' do
    let(:instance) { SequelItem.first }

    it { expect(instance.surrealize).to eq({ name: 'testing sequel' }.to_json) }
    it_behaves_like 'error is not raised for valid params: instance'
    it_behaves_like 'error is raised for invalid params: instance'
  end

  describe 'collections' do
    let(:collection) { SequelItem.all }
    let(:subject) { Surrealist.surrealize_collection(collection) }

    it { is_expected.to eq([{ name: 'testing sequel' }].to_json) }

    it_behaves_like 'error is not raised for valid params: collection'
    it_behaves_like 'error is raised for invalid params: collection'
  end
end
