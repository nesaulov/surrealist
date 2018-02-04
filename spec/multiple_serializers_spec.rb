class ShortPostSerializer < Surrealist::Serializer
  json_schema do
    {
      id: Integer,
      title: String,
    }
  end
end

class FullPostSerializer < Surrealist::Serializer
  json_schema do
    {
      id: Integer,
      title: String,
      author: {
        name: String,
      },
    }
  end
end

class Post
  include Surrealist

  surrealize_with FullPostSerializer
  surrealize_with ShortPostSerializer, tag: :short

  attr_reader :id, :title, :author

  def initialize(id, title, author)
    @id = id
    @title = title
    @author = author
  end
end

RSpec.describe 'Multiple serializers' do
  let(:author) { Struct.new(:name).new('John') }
  let(:post) { Post.new(1, 'Ruby is dead', author) }

  describe 'single item' do
    context 'default' do
      let(:expectation) { Hash[id: 1, title: 'Ruby is dead', author: { name: 'John' }] }

      it { expect(post.surrealize).to eq(expectation.to_json) }
    end

    context 'specific' do
      let(:expectation) { Hash[id: 1, title: 'Ruby is dead'] }

      it { expect(post.surrealize(tag: :short)).to eq(expectation.to_json) }
    end

    context 'unknown tag passed' do
      it 'raises error' do
        expect { post.surrealize(tag: :kek) }
          .to raise_error Surrealist::UnknownTagError,
                          'The tag specified (kek) has no corresponding serializer'
      end
    end
  end

  describe 'collection' do
    let(:collection) { [post, post, post] }

    context 'default' do
      let(:expectation) do
        [
          { id: 1, title: 'Ruby is dead', author: { name: 'John' } },
          { id: 1, title: 'Ruby is dead', author: { name: 'John' } },
          { id: 1, title: 'Ruby is dead', author: { name: 'John' } },
        ]
      end

      it { expect(Surrealist.surrealize_collection(collection)).to eq(expectation.to_json) }
    end

    context 'specific' do
      let(:expectation) do
        [
          { id: 1, title: 'Ruby is dead' },
          { id: 1, title: 'Ruby is dead' },
          { id: 1, title: 'Ruby is dead' },
        ]
      end

      let(:json) { Surrealist.surrealize_collection(collection, tag: :short) }

      it { expect(json).to eq(expectation.to_json) }
    end
  end
end
