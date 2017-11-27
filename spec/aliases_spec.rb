class User
  include Surrealist

  json_aliases avatar: :image

  json_schema do
    { avatar: String }
  end

  def image
    'http://some-image.host/avatar/neo.jpg'
  end
end

class WrongUser
  include Surrealist

  json_aliases avatar: :image

  json_schema do
    { avatar: String }
  end

  def picture
    'http://some-image.host/avatar/neo.jpg'
  end
end

class UndecidedUser
  include Surrealist

  json_aliases avatar: :image

  json_schema do
    { image: String }
  end

  def image
    'http://some-image.host/avatar/neo.jpg'
  end
end

RSpec.describe Surrealist do
  describe '#json_aliases' do
    subject(:json) { JSON.parse(instance.surrealize) }

    context 'with existing method' do
      let(:instance) { User.new }

      it 'uses alias method' do
        expect(json).to eq('avatar' => 'http://some-image.host/avatar/neo.jpg')
      end
    end

    context 'with wrong method name' do
      let(:instance) { WrongUser.new }

      it 'raises exception' do
        expect { json }.to raise_error Surrealist::UndefinedMethodError
      end
    end

    context 'with useless alias' do
      let(:instance) { UndecidedUser.new }

      it 'ignores aliases' do
        expect(json).to eq('image' => 'http://some-image.host/avatar/neo.jpg')
      end
    end
  end
end