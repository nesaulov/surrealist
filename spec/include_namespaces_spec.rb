# frozen_string_literal: true

module BusinessSystem
  class Cashout
    class ReportSystem
      include Surrealist

      json_schema do
        { kind: Array }
      end

      def kind
        %w[withdraws deposits]
      end
    end
  end
end

class BusinessSystem::Cashout::ReportSystem::Withdraws
  include Surrealist

  json_schema do
    { withdraws_amount: Integer }
  end

  def withdraws_amount
    34
  end
  # expecting: business_system: { cashout: { report_system: {
  #   withdraws: { withdraws_amount: 34 }
  # } } }
end

RSpec.describe Surrealist do
  describe 'include_namespaces optional argument' do
    let(:instance) { BusinessSystem::Cashout::ReportSystem::Withdraws.new }

    context 'without level of nesting' do
      let(:snake_hash) do
        {
          business_system: {
            cashout: { report_system: { withdraws: { withdraws_amount: 34 } } },
          },
        }
      end
      let(:camel_hash) do
        {
          businessSystem: {
            cashout: { reportSystem: { withdraws: { withdrawsAmount: 34 } } },
          },
        }
      end
      let(:snake_json) do
        {
          'business_system' => { 'cashout' => { 'report_system' => {
            'withdraws' => { 'withdraws_amount' => 34 },
          } } },
        }
      end
      let(:camel_json) do
        {
          'businessSystem' => { 'cashout' => { 'reportSystem' => {
            'withdraws' => { 'withdrawsAmount' => 34 },
          } } },
        }
      end

      it 'builds schema' do
        expect(instance.build_schema(include_namespaces: true)).to eq(snake_hash)
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_namespaces: true))).to eq(snake_json)
      end

      it 'camelizes' do
        expect(instance.build_schema(include_namespaces: true, camelize: true)).to eq(camel_hash)

        expect(JSON.parse(instance.surrealize(include_namespaces: true, camelize: true)))
          .to eq(camel_json)
      end

      specify 'include_root is ignored' do
        expect(instance.build_schema(include_namespaces: true, include_root: true))
          .to eq(snake_hash)

        expect(JSON.parse(instance.surrealize(include_namespaces: true, include_root: true)))
          .to eq(snake_json)

        expect(instance.build_schema(include_namespaces: true, camelize: true, include_root: true))
          .to eq(camel_hash)

        expect(JSON.parse(
                 instance.surrealize(include_namespaces: true, camelize: true, include_root: true),
        )).to eq(camel_json)
      end
    end

    context 'with `namespaces_nesting_level`' do
      describe '#build_schema' do
        let(:expectations) do
          [
            { withdraws: { withdraws_amount: 34 } },
            { report_system: { withdraws: { withdraws_amount: 34 } } },
            { cashout: { report_system: { withdraws: { withdraws_amount: 34 } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { withdraws: { withdraws_amount: 34 } },
            { report_system: { withdraws: { withdraws_amount: 34 } } },
            { cashout: { report_system: { withdraws: { withdraws_amount: 34 } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { withdraws: { withdrawsAmount: 34 } },
            { reportSystem: { withdraws: { withdrawsAmount: 34 } } },
            { cashout: { reportSystem: { withdraws: { withdrawsAmount: 34 } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                               { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { businessSystem: { cashout: { reportSystem: { withdraws:
                                                             { withdrawsAmount: 34 } } } } },
            { withdraws: { withdraws_amount: 34 } },
            { report_system: { withdraws: { withdraws_amount: 34 } } },
            { cashout: { report_system: { withdraws: { withdraws_amount: 34 } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
            { business_system: { cashout: { report_system: { withdraws:
                                                               { withdraws_amount: 34 } } } } },
          ]
        end

        [
          { include_namespaces: true, namespaces_nesting_level: 1 },
          { include_namespaces: true, namespaces_nesting_level: 2 },
          { include_namespaces: true, namespaces_nesting_level: 3 },
          { include_namespaces: true, namespaces_nesting_level: 4 },
          { include_namespaces: true, namespaces_nesting_level: 5 },
          { include_namespaces: true, namespaces_nesting_level: 6 },
          { include_namespaces: true, namespaces_nesting_level: 7 },
          { include_namespaces: true, namespaces_nesting_level: 8 },
          { include_namespaces: true, namespaces_nesting_level: 9 },
          { include_namespaces: true, namespaces_nesting_level: 10 },
          { include_namespaces: true, namespaces_nesting_level: 999 },
          { namespaces_nesting_level: 1, include_root: true },
          { namespaces_nesting_level: 2, include_root: true },
          { namespaces_nesting_level: 3, include_root: true },
          { namespaces_nesting_level: 4, include_root: true },
          { namespaces_nesting_level: 5, include_root: true },
          { namespaces_nesting_level: 6, include_root: true },
          { namespaces_nesting_level: 7, include_root: true },
          { namespaces_nesting_level: 8, include_root: true },
          { namespaces_nesting_level: 9, include_root: true },
          { namespaces_nesting_level: 10, include_root: true },
          { namespaces_nesting_level: 999, include_root: true },
          { namespaces_nesting_level: 1, camelize: true },
          { namespaces_nesting_level: 2, camelize: true },
          { namespaces_nesting_level: 3, camelize: true },
          { namespaces_nesting_level: 4, camelize: true },
          { namespaces_nesting_level: 5, camelize: true },
          { namespaces_nesting_level: 6, camelize: true },
          { namespaces_nesting_level: 7, camelize: true },
          { namespaces_nesting_level: 8, camelize: true },
          { namespaces_nesting_level: 9, camelize: true },
          { namespaces_nesting_level: 10, camelize: true },
          { namespaces_nesting_level: 999, camelize: true },
          { namespaces_nesting_level: 1 },
          { namespaces_nesting_level: 2 },
          { namespaces_nesting_level: 3 },
          { namespaces_nesting_level: 4 },
          { namespaces_nesting_level: 5 },
          { namespaces_nesting_level: 6 },
          { namespaces_nesting_level: 7 },
          { namespaces_nesting_level: 8 },
          { namespaces_nesting_level: 9 },
          { namespaces_nesting_level: 10 },
          { namespaces_nesting_level: 999 },
        ].each_with_index do |hash, index|
          it "works with #{hash} arguments" do
            expect(instance.build_schema(hash))
              .to eq(expectations[index])
          end
        end

        context 'with invalid namespaces_nesting_level provided' do
          [
            { include_namespaces: true, namespaces_nesting_level: 0 },
            { include_namespaces: true, namespaces_nesting_level: -2 },
            { include_namespaces: true, namespaces_nesting_level: '2' },
            { include_namespaces: true, namespaces_nesting_level: 2.4 },
            { include_namespaces: true, namespaces_nesting_level: -4.4 },
            { include_namespaces: true, namespaces_nesting_level: '-4' },
            { include_namespaces: true, namespaces_nesting_level: true },
            { include_namespaces: true, namespaces_nesting_level: 'none' },
            { include_namespaces: true, namespaces_nesting_level: String },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: 0 },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: -2 },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: '2' },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: 2.4 },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: -4.4 },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: '-4' },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: true },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: 'none' },
            { include_root: true, include_namespaces: true, namespaces_nesting_level: String },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: 0 },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: -2 },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: '2' },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: 2.4 },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: -4.4 },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: '-4' },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: true },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: 'none' },
            { camelize: true, include_namespaces: true, namespaces_nesting_level: String },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: 0 },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: -2 },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: '2' },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: 2.4 },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: -4.4 },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: '-4' },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: true },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: 'none' },
            { include_root: true, camelize: true, include_namespaces: true,
              namespaces_nesting_level: String },
          ].each do |hash|
            it "raises ArgumentError for nesting_level: #{hash[:namespaces_nesting_level]}" do
              expect { instance.build_schema(hash) }
                .to raise_error(ArgumentError,
                                /Expected `namespaces_nesting_level` to be a positive integer, got/)
            end
          end
        end
      end
    end
  end
end
