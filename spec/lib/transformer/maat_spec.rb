require 'rails_helper'

describe Transformer::MAAT do
  describe '.chop!' do
    subject(:result) do
      described_class.chop!(obj, criteria)
    end

    let(:obj) do
      {
        'organisation' => 'Ministry of Justice at 102 Petty France',
        'city' => 'London',
        'people' => 200,
      }
    end

    let(:criteria) { nil }

    context 'when criteria is a hash' do
      let(:criteria) do
        {
          'organisation' => 22,
        }
      end

      it 'chops hash values based on supplied criteria' do
        expect(result).to eq(
          'organisation' => 'Ministry of Justice...',
          'city' => 'London',
          'people' => 200,
        )

        expect(result['organisation'].length).to eq 22
      end
    end

    context 'when criteria is a number' do
      let(:criteria) { 5 }

      it 'chops hash values down to criteria length' do
        expect(result).to eq(
          'organisation' => 'Mi...',
          'city' => 'Lo...',
          'people' => 200,
        )

        expect(result['organisation'].length).to eq 5
      end
    end

    context 'when obj is a string' do
      let(:obj) { 'My string' }
      let(:criteria) { 5 }

      it { is_expected.to eq 'My...' }
    end

    context 'when obj is neither a String nor a Hash' do
      let(:obj) { 42 }
      let(:criteria) { 5 }

      it { is_expected.to eq 42 }
    end

    context 'when obj is nil' do
      let(:obj) { nil }

      it { is_expected.to be_nil }
    end

    context 'with missing criteria' do
      let(:criteria) { nil }

      it { is_expected.to eq obj }
    end
  end

  describe '.truncate!' do
    it 'appends ...' do
      expect(described_class.truncate!('United Kingdom', 9)).to eq 'United...'
    end
  end

  describe '#transform!' do
    context 'with a Grape Entity like object' do
      let(:property_owner) do
        Class.new do
          include Transformer::MAAT

          def other_relationship
            transform!('other_relationship', rule: 'property_owner')
          end

          def name
            transform!(
              'name',
              fallback: %w[metadata surname],
              rule: 'property_owner'
            )
          end

          def object
            {
              'name' => nil,
              'other_relationship' => 'Friend',
              'metadata' => {
                'surname' => 'Fallback-Name',
              }
            }
          end
        end
      end

      it 'returns the specified key value from object' do
        expect(property_owner.new.other_relationship).to eq 'Friend'
      end

      it 'returns fallback key value from object' do
        expect(property_owner.new.name).to eq 'Fallback-Name'
      end
    end

    # The main Application does not always work with Grape::Entity objects
    context 'with a hash' do
      let(:application) do
        Class.new do
          include Transformer::MAAT

          # rubocop:disable Metrics/MethodLength
          def initialize
            @hash = {
              'client_details' => {
                'applicant' => {
                  'home_address' => {
                    'postcode' => 'SW7 7LAXXXXXXX',
                  },
                  'first_name' => 'Sara',
                  'last_name' => 'Box',
                },
                'partner' => {
                  'first_name' => 'Zoe',
                  'last_name' => 'Tall' * 200,
                },
              }
            }
          end
          # rubocop:enable Metrics/MethodLength

          # NOTE: transform! called for each nested section of client_details
          # TOOD: transform! called once with top level client_details and RULES applied
          # recursively
          def client_details
            applicant = @hash['client_details']['applicant']
            partner = @hash['client_details']['partner']

            transform!(applicant, rule: %w[client_details applicant])
            transform!(applicant['home_address'], rule: %w[client_details applicant home_address])
            transform!(partner, rule: %w[client_details partner])

            @hash
          end
        end
      end

      # rubocop:disable RSpec/ExampleLength
      it 'returns the transformed hash without recursively applying rules' do
        app = application.new

        expect(app.client_details).to eq(
          {
            'client_details' => {
              'applicant' => {
                'first_name' => 'Sara',
                'home_address' => {
                  'postcode' => 'SW7 7LA...'
                },
                'last_name' => 'Box',
              },
              'partner' => {
                'first_name' => 'Zoe',
                'last_name' => 'TallTallTallTallTallTallTallTallTallT...'
              }
            }
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
