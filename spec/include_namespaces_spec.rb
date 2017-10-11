# frozen_string_literal: true

require_relative '../lib/surrealist'
require 'dry-types'

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
        it 'works with all numbers' do
          expect { instance.build_schema(include_namespaces: true, namespaces_nesting_level: 0) }
            .to raise_error(ArgumentError,
                            'Expected `namespaces_nesting_level` to be a positive integer, got: 0')

          expect(instance.build_schema(include_namespaces: true, namespaces_nesting_level: 1))
            .to eq(withdraws: { withdraws_amount: 34 })

          expect(instance.build_schema(include_namespaces: true, namespaces_nesting_level: 2))
            .to eq(report_system: { withdraws: { withdraws_amount: 34 } })

          expect(instance.build_schema(include_namespaces: true, namespaces_nesting_level: 3))
            .to eq(cashout: { report_system: { withdraws: { withdraws_amount: 34 } } })

          expect(instance.build_schema(include_namespaces: true, namespaces_nesting_level: 4))
            .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                    { withdraws_amount: 34 } } } })

          expect(instance.build_schema(include_namespaces: true, namespaces_nesting_level: 5))
            .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                    { withdraws_amount: 34 } } } })

          expect(instance.build_schema(include_namespaces: true, namespaces_nesting_level: 9933))
            .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                    { withdraws_amount: 34 } } } })
        end

        it 'camelizes' do
          expect do
            instance.build_schema(include_namespaces: true,
                                  namespaces_nesting_level: 0,
                                  camelize: true)
          end.to raise_error(ArgumentError,
                             'Expected `namespaces_nesting_level` to be a positive integer, got: 0')

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 1,
                                       camelize: true))
            .to eq(withdraws: { withdrawsAmount: 34 })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 2,
                                       camelize: true))
            .to eq(reportSystem: { withdraws: { withdrawsAmount: 34 } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 3,
                                       camelize: true))
            .to eq(cashout: { reportSystem: { withdraws: { withdrawsAmount: 34 } } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 4,
                                       camelize: true))
            .to eq(businessSystem: { cashout: { reportSystem: { withdraws:
                                                                    { withdrawsAmount: 34 } } } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 5,
                                       camelize: true))
            .to eq(businessSystem: { cashout: { reportSystem: { withdraws:
                                                                    { withdrawsAmount: 34 } } } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 9933,
                                       camelize: true))
            .to eq(businessSystem: { cashout: { reportSystem: { withdraws:
                                                                    { withdrawsAmount: 34 } } } })
        end

        it 'ignores include_root' do
          expect do
            instance.build_schema(include_namespaces: true,
                                  namespaces_nesting_level: 0,
                                  include_root: true)
          end.to raise_error(ArgumentError,
                             'Expected `namespaces_nesting_level` to be a positive integer, got: 0')

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 1,
                                       include_root: true))
            .to eq(withdraws: { withdraws_amount: 34 })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 2,
                                       include_root: true))
            .to eq(report_system: { withdraws: { withdraws_amount: 34 } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 3,
                                       include_root: true))
            .to eq(cashout: { report_system: { withdraws: { withdraws_amount: 34 } } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 4,
                                       include_root: true))
            .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                    { withdraws_amount: 34 } } } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 5,
                                       include_root: true))
            .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                    { withdraws_amount: 34 } } } })

          expect(instance.build_schema(include_namespaces: true,
                                       namespaces_nesting_level: 9933,
                                       include_root: true))
            .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                    { withdraws_amount: 34 } } } })
        end

        context 'treats `include_namespaces` as true if `namespaces_nesting_level` is provided' do
          specify 'with `include_root`' do
            expect do
              instance.build_schema(namespaces_nesting_level: 0, include_root: true)
            end.to raise_error(ArgumentError,
                               'Expected `namespaces_nesting_level` to be a positive integer, got: 0')

            expect(instance.build_schema(namespaces_nesting_level: 1, include_root: true))
              .to eq(withdraws: { withdraws_amount: 34 })

            expect(instance.build_schema(namespaces_nesting_level: 2, include_root: true))
              .to eq(report_system: { withdraws: { withdraws_amount: 34 } })

            expect(instance.build_schema(namespaces_nesting_level: 3, include_root: true))
              .to eq(cashout: { report_system: { withdraws: { withdraws_amount: 34 } } })

            expect(instance.build_schema(namespaces_nesting_level: 4, include_root: true))
              .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                      { withdraws_amount: 34 } } } })

            expect(instance.build_schema(namespaces_nesting_level: 5, include_root: true))
              .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                      { withdraws_amount: 34 } } } })

            expect(instance.build_schema(namespaces_nesting_level: 9933, include_root: true))
              .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                      { withdraws_amount: 34 } } } })
          end

          specify 'with `camelize`' do
            expect do
              instance.build_schema(namespaces_nesting_level: 0, camelize: true)
            end.to raise_error(ArgumentError,
                               'Expected `namespaces_nesting_level` to be a positive integer, got: 0')

            expect(instance.build_schema(namespaces_nesting_level: 1, camelize: true))
              .to eq(withdraws: { withdrawsAmount: 34 })

            expect(instance.build_schema(namespaces_nesting_level: 2, camelize: true))
              .to eq(reportSystem: { withdraws: { withdrawsAmount: 34 } })

            expect(instance.build_schema(namespaces_nesting_level: 3, camelize: true))
              .to eq(cashout: { reportSystem: { withdraws: { withdrawsAmount: 34 } } })

            expect(instance.build_schema(namespaces_nesting_level: 4, camelize: true))
              .to eq(businessSystem: { cashout: { reportSystem: { withdraws:
                                                                    { withdrawsAmount: 34 } } } })

            expect(instance.build_schema(namespaces_nesting_level: 5, camelize: true))
              .to eq(businessSystem: { cashout: { reportSystem: { withdraws:
                                                                    { withdrawsAmount: 34 } } } })

            expect(instance.build_schema(namespaces_nesting_level: 9933, camelize: true))
              .to eq(businessSystem: { cashout: { reportSystem: { withdraws:
                                                                    { withdrawsAmount: 34 } } } })
          end

          specify 'only with `namespaces_nesting_level`' do
            expect { instance.build_schema(namespaces_nesting_level: 0) }
              .to raise_error(ArgumentError,
                              'Expected `namespaces_nesting_level` to be a positive integer, got: 0')

            expect(instance.build_schema(namespaces_nesting_level: 1))
              .to eq(withdraws: { withdraws_amount: 34 })

            expect(instance.build_schema(namespaces_nesting_level: 2))
              .to eq(report_system: { withdraws: { withdraws_amount: 34 } })

            expect(instance.build_schema(namespaces_nesting_level: 3))
              .to eq(cashout: { report_system: { withdraws: { withdraws_amount: 34 } } })

            expect(instance.build_schema(namespaces_nesting_level: 4))
              .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                      { withdraws_amount: 34 } } } })

            expect(instance.build_schema(namespaces_nesting_level: 5))
              .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                      { withdraws_amount: 34 } } } })

            expect(instance.build_schema(namespaces_nesting_level: 9933))
              .to eq(business_system: { cashout: { report_system: { withdraws:
                                                                      { withdraws_amount: 34 } } } })
          end
        end
      end
    end
  end
end
