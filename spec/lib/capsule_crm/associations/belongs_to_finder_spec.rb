require 'spec_helper'

describe CapsuleCRM::Associations::BelongsToFinder do
  before { configure }

  describe '#call' do
    let(:association) do
      double(
        'CapsuleCRM::Associations::BelongsToAssociation', inverse: inverse
      )
    end
    let(:inverse) do
      double('CapsuleCRM::Associations::HasManyAssociation', embedded: false)
    end
    let(:normalizer) do
      double('CapsuleCRM::Normalizer', normalize_collection: [])
    end
    let(:finder) { described_class.new(association) }

    before do
      finder.singular = 'person'
      finder.plural = 'customfields'
      finder.normalizer = normalizer
    end

    context 'when an ID is supplied' do
      before do
        stub_request(:get, /.*/).
          to_return(body: File.read('spec/support/all_customfields.json'))
      end
      subject { finder.call(1) }

      it 'should send a request' do
        subject
        expect(WebMock).to have_requested(
          :get, "https://1234:@company.capsulecrm.com/api/person/1/customfields"
        )
      end
    end

    context 'when a nil ID is supplied' do
      subject { finder.call(nil) }

      it 'should return an array' do
        expect(subject).to be_a(Array)
      end
    end
  end
end
