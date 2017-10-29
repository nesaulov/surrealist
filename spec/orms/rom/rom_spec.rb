# frozen_string_literal: true

require_relative 'models'
require_relative '../../../lib/surrealist'
require_relative '../../carriers/params'

RSpec.describe 'ROM integration' do
  describe 'Surrealist.surrealize_collection()' do
    it 'works' do
      expect(subject.surrealize_collection(rom.relation(:items).all))
        .to eq([{ name: 'testing rom' }].to_json)
    end
  end
end
