# frozen_string_literal: true

require_relative '../lib/surrealist'

TestClass = Class.new do
  include Surrealist

  json_schema { { id_num: Integer } }

  def id_num
    2
  end
end

RSpec.describe Surrealist do
  let(:instance) { TestClass.new }
  after { Surrealist.configure(nil) }

  describe '.configure(hash)' do
    before { Surrealist.configure(nil) }

    context 'without config' do
      it { expect(instance.build_schema(root: :test)).to eq(test: { id_num: 2 }) }
    end

    context 'with config' do
      before { Surrealist.configure(root: :nope, camelize: true) }

      it 'applies config' do
        expect(instance.build_schema).to eq(nope: { idNum: 2 })
      end

      it 'merges arguments' do
        expect(instance.build_schema(root: :test)).to eq(test: { idNum: 2 })
      end

      it 'applies to other classes as well' do
        New = Class.new do
          include Surrealist

          json_schema { { one_two: String } }

          def one_two
            '12'
          end
        end

        expect(New.new.build_schema).to eq(nope: { oneTwo: '12' })
      end

      it 'is accessible as .config()' do
        expect(Surrealist.config).to eq(camelize: true, root: :nope)
      end
    end
  end

  describe '.configure {  }' do
    context 'with config' do
      before { Surrealist.configure { |c| c.root = :new } }

      it 'applies config' do
        expect(instance.build_schema).to eq(new: { id_num: 2 })
      end

      it 'merges arguments' do
        expect(instance.build_schema(root: :test)).to eq(test: { id_num: 2 })
      end

      it 'applies to other classes as well' do
        Loop = Class.new do
          include Surrealist

          json_schema { { one_two: String } }

          def one_two
            '12'
          end
        end

        expect(Loop.new.build_schema).to eq(new: { one_two: '12' })
      end

      it 'is accessible as .config() (with all other args merged)' do
        expect(Surrealist.config)
            .to eq(camelize: false, include_root: false, include_namespaces: false,
                   root: :new, namespaces_nesting_level: 666)
      end
    end
  end

  describe '.configure {  } && .configure(hash)' do
    before { Surrealist.configure { |c| c.root = :new } }

    describe 'last write wins' do
      before { Surrealist.configure(root: :nope, camelize: true) }

      it { expect(instance.build_schema).to eq(nope: { idNum: 2 }) }
    end
  end

  describe '.configure(hash) && .configure {  }' do
    before { Surrealist.configure(root: :nope, camelize: true) }

    describe 'last write wins' do
      before { Surrealist.configure { |c| c.root = :new } }

      it { expect(instance.build_schema).to eq(new: { id_num: 2 }) }
    end
  end
end
