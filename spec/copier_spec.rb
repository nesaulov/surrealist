# frozen_string_literal: true

RSpec.describe Surrealist::Copier do
  describe '#deep_copy' do
    let(:object) { { animal: { kind: 'dog', name: 'Rusty' } } }

    it_behaves_like 'hash is cloned deeply and it`s structure is not changed' do
      let(:copy) { Surrealist::Copier.deep_copy(object) }
    end
  end
end
