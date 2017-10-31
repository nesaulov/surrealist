# frozen_string_literal: true

require 'date'

class ExampleClass; end

RSpec.describe 'Dry-types with invalid scenarios' do
  shared_examples 'type error is raised' do
    it { expect { instance.build_schema }.to raise_error(Surrealist::InvalidTypeError) }
  end

  context 'with strict types' do
    context 'nil' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_nil: Types::Strict::Nil } }

          def a_nil; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'symbol' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_symbol: Types::Strict::Symbol } }

          def a_symbol; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'class' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_class: Types::Strict::Class } }

          def a_class; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'true' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_true: Types::Strict::True } }

          def a_true; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'false' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_false: Types::Strict::False } }

          def a_false; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'bool' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_false: Types::Strict::Bool } }

          def a_false; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'int' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { an_int: Types::Strict::Int } }

          def an_int; '23'; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'float' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_float: Types::Strict::Float } }

          def a_float; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'decimal' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_decimal: Types::Strict::Decimal } }

          def a_decimal; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'string' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_string: Types::Strict::String } }

          def a_string; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'array' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { an_array: Types::Strict::Array } }

          def an_array; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'hash' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { a_hash: Types::Strict::Hash } }

          def a_hash; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end
  end

  context 'with constrainted types' do
    context 'integer' do
      let(:instance) do
        Class.new(Object) do
          include Surrealist
          json_schema { { an_int: Types::Strict::Int.constrained(gteq: 29) } }

          def an_int; 23; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'string - format' do
      let(:instance) do
        Class.new do
          include Surrealist
          json_schema do
            {
              a_string: Types::Strict::String.constrained(
                format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i,
              ),
            }
          end

          def a_string; 'johndoeATemail.com'; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end

    context 'string - size' do
      let(:instance) do
        Class.new do
          include Surrealist
          json_schema { { a_string: Types::Strict::String.constrained(min_size: 3) } }

          def a_string; '2'; end
        end.new
      end

      it_behaves_like 'type error is raised'
    end
  end
end
