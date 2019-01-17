# frozen_string_literal: true

shared_examples 'hash is cloned deeply and it`s structure is not changed' do
  specify do
    expect(copy).to eq(object)
    expect(copy).to eql(object)
  end
end
