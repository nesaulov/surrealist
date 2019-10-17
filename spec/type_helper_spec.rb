# frozen_string_literal: true

# RSpec.describe Surrealist::TypeHelper do
#   describe '#valid_type?' do
#     context 'nil values' do
#       context 'plain ruby classes' do
#         [
#           [nil, String],
#           [nil, Integer],
#           [nil, Array],
#           [nil, Object],
#           [nil, Any],
#           [nil, Float],
#           [nil, Hash],
#           [nil, BigDecimal],
#           [nil, Symbol],
#         ].each do |params|
#           it "returns true for #{params} because value is nil" do
#             expect(described_class.valid_type?(*params)).to eq true
#           end
#         end
#       end

#       context 'optional dry-types' do
#         [
#           [nil, Types::Any],
#           [nil, Types::Form::Nil],
#           [nil, Types::Json::Nil],
#           [nil, Types::String.optional],
#           [nil, Types::Int.optional],
#           [nil, Types::Array.optional],
#           [nil, Types::Bool.optional],
#           [nil, Types::Any.optional],
#           [nil, Types::Any.optional],
#           [nil, Types::Symbol.optional],
#           [nil, Types::Class.optional],
#           [nil, Types::True.optional],
#           [nil, Types::False.optional],
#           [nil, Types::Float.optional],
#           [nil, Types::Decimal.optional],
#           [nil, Types::Hash.optional],
#           [nil, Types::Date.optional],
#           [nil, Types::DateTime.optional],
#           [nil, Types::Time.optional],
#           [nil, Types::Form::Nil.optional],
#           [nil, Types::Form::Date.optional],
#           [nil, Types::Form::DateTime.optional],
#           [nil, Types::Form::True.optional],
#           [nil, Types::Form::False.optional],
#           [nil, Types::Form::Bool.optional],
#           [nil, Types::Form::Int.optional],
#           [nil, Types::Form::Float.optional],
#           [nil, Types::Form::Decimal.optional],
#           [nil, Types::Form::Array.optional],
#           [nil, Types::Form::Hash.optional],
#           [nil, Types::Json::Nil.optional],
#           [nil, Types::Json::Date.optional],
#           [nil, Types::Json::DateTime.optional],
#           [nil, Types::Json::Time.optional],
#           [nil, Types::Json::Decimal.optional],
#           [nil, Types::Json::Array.optional],
#           [nil, Types::Json::Hash.optional],
#         ].each do |params|
#           it "returns true for #{params} because value is nil and type is not strict" do
#             expect(described_class.valid_type?(*params)).to eq true
#           end
#         end
#       end

#       context 'non-optional dry-types' do
#         [
#           [nil, Types::String],
#           [nil, Types::Int],
#           [nil, Types::Array],
#           [nil, Types::Bool],
#           [nil, Types::Symbol],
#           [nil, Types::Class],
#           [nil, Types::True],
#           [nil, Types::False],
#           [nil, Types::Float],
#           [nil, Types::Decimal],
#           [nil, Types::Hash],
#           [nil, Types::Date],
#           [nil, Types::DateTime],
#           [nil, Types::Time],
#           [nil, Types::Form::Date],
#           [nil, Types::Form::DateTime],
#           [nil, Types::Form::True],
#           [nil, Types::Form::False],
#           [nil, Types::Form::Bool],
#           [nil, Types::Form::Int],
#           [nil, Types::Form::Float],
#           [nil, Types::Form::Decimal],
#           [nil, Types::Form::Array],
#           [nil, Types::Form::Hash],
#           [nil, Types::Json::Date],
#           [nil, Types::Json::DateTime],
#           [nil, Types::Json::Time],
#           [nil, Types::Json::Array],
#           [nil, Types::Json::Hash],
#         ].each do |params|
#           it "returns false for #{params} because value is nil" do
#             expect(described_class.valid_type?(*params)).to eq false
#           end
#         end
#       end

#       context 'strict dry-types' do
#         [
#           [nil, Types::Strict::Class],
#           [nil, Types::Strict::True],
#           [nil, Types::Strict::False],
#           [nil, Types::Strict::Bool],
#           [nil, Types::Strict::Int],
#           [nil, Types::Strict::Float],
#           [nil, Types::Strict::Decimal],
#           [nil, Types::Strict::String],
#           [nil, Types::Strict::Date],
#           [nil, Types::Strict::DateTime],
#           [nil, Types::Strict::Time],
#           [nil, Types::Strict::Array],
#           [nil, Types::Strict::Hash],
#         ].each do |params|
#           it "returns false for #{params} because value is nil & type is strict" do
#             expect(described_class.valid_type?(*params)).to eq false
#           end
#         end
#       end

#       context 'coercible dry-types' do
#         context 'types that can be coerced from nil' do
#           [
#             [nil, Types::Coercible::String],
#             [nil, Types::Coercible::Array],
#             [nil, Types::Coercible::Hash],
#           ].each do |params|
#             it "returns true for #{params} because nil can be coerced" do
#               expect(described_class.valid_type?(*params)).to eq true
#             end
#           end
#         end

#         context 'types that can\'t be coerced' do
#           [
#             [nil, Types::Coercible::Int],
#             [nil, Types::Coercible::Float],
#             [nil, Types::Coercible::Decimal],
#           ].each do |params|
#             it "returns false for #{params} because nil can't be coerced" do
#               expect(described_class.valid_type?(*params)).to eq false
#             end
#           end
#         end
#       end
#     end

#     context 'string values' do
#       [
#         ['string', String],
#         ['string', Types::String],
#         ['string', Types::Coercible::String],
#         ['string', Types::Strict::String],
#         ['string', Types::String.optional],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end

#     context 'integer values' do
#       [
#         [666, Integer],
#         [666, Types::Int],
#         [666, Types::Int.optional],
#         [666, Types::Strict::Int],
#         [666, Types::Coercible::Int],
#         [666, Types::Form::Int],
#         [666, Types::Form::Int.optional],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end

#     context 'array values' do
#       [
#         [%w[an array], Array],
#         [%w[an array], Types::Array],
#         [%w[an array], Types::Array.optional],
#         [%w[an array], Types::Strict::Array],
#         [%w[an array], Types::Json::Array],
#         [%w[an array], Types::Json::Array.optional],
#         [%w[an array], Types::Form::Array],
#         [%w[an array], Types::Form::Array.optional],
#         [%w[an array], Types::Coercible::Array],
#         [%w[an array], Types::Coercible::Array.optional],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end

#     context 'hash values' do
#       [
#         [{ a: :b }, Hash],
#         [{ a: :b }, Types::Hash],
#         [{ a: :b }, Types::Hash.optional],
#         [{ a: :b }, Types::Strict::Hash],
#         [{ a: :b }, Types::Form::Hash],
#         [{ a: :b }, Types::Form::Hash.optional],
#         [{ a: :b }, Types::Json::Hash],
#         [{ a: :b }, Types::Json::Hash.optional],
#         [{ a: :b }, Types::Coercible::Hash],
#         [{ a: :b }, Types::Coercible::Hash.optional],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end

#     context 'any values' do
#       [
#         [nil, Any],
#         ['nil', Any],
#         [:nil, Any],
#         [[nil], Any],
#         [{ nil: :nil }, Any],
#         [nil, Types::Any],
#         ['nil', Types::Any],
#         [:nil, Types::Any],
#         [[nil], Types::Any],
#         [{ nil: :nil }, Types::Any],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end

#     context 'boolean values' do
#       [
#         [true, Bool],
#         [false, Bool],
#         [false, Types::Bool],
#         [true, Types::Bool],
#         [nil, Bool],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end

#     context 'symbol values' do
#       [
#         [:sym, Symbol],
#         [:sym, Types::Symbol],
#         [:sym, Types::Symbol.optional],
#         [:sym, Types::Strict::Symbol],
#       ].each do |params|
#         it "returns true for #{params}" do
#           expect(described_class.valid_type?(*params)).to eq true
#         end
#       end
#     end
#   end

#   describe '#coerce' do
#     [
#       [nil, String],
#       [nil, Integer],
#       [nil, Array],
#       [nil, Object],
#       [nil, Any],
#       [nil, Float],
#       [nil, Hash],
#       [nil, BigDecimal],
#       [nil, Symbol],
#       ['something', String],
#       ['something', Integer],
#       ['something', Array],
#       ['something', Object],
#       ['something', Any],
#       ['something', Float],
#       ['something', Hash],
#       ['something', BigDecimal],
#       ['something', Symbol],
#     ].each do |params|
#       it "returns value for non-dry-types for #{params}" do
#         expect(described_class.coerce(*params)).to eq(params.first)
#       end
#     end

#     [
#       ['smth', Types::String],
#       [23, Types::Int],
#       [[2], Types::Array],
#       [true, Types::Bool],
#       [:sym, Types::Symbol],
#       [Array, Types::Class],
#       [true, Types::True],
#       [false, Types::False],
#       [2.4, Types::Float],
#       [35.4, Types::Decimal],
#       [{ k: :v }, Types::Hash],
#       [Date.new, Types::Date],
#       [DateTime.new, Types::DateTime],
#       [Time.new, Types::Time],
#       [Date.new, Types::Form::Date],
#       [DateTime.new, Types::Form::DateTime],
#       [true, Types::Form::True],
#       [false, Types::Form::False],
#       [true, Types::Form::Bool],
#       [3, Types::Form::Int],
#       [3.5, Types::Form::Float],
#       [56.2, Types::Form::Decimal],
#       [%w[ar ray], Types::Form::Array],
#       [{ k: :v }, Types::Form::Hash],
#       [Date.new, Types::Json::Date],
#       [DateTime.new, Types::Json::DateTime],
#       [Time.new, Types::Json::Time],
#       [%w[ar ray], Types::Json::Array],
#       [{ k: :v }, Types::Json::Hash],
#     ].each do |params|
#       it "returns value if it doesn't have to be coerced for #{params}" do
#         expect(described_class.coerce(*params)).to eq(params.first)
#       end
#     end
#   end

#   # Testing coercing itself is kind of pointless, because dry-types have enough specs in their repo.
# end
