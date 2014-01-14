require 'spec_helper'

describe CapsuleCRM::CustomFieldDefinition do
  before { configure }

  describe '.for_parties' do
    context 'when some definitions are returned' do
      before do
        stub_request(:get, /.*/).
          to_return(body: File.read('spec/support/custom_field_definitions.json'))
      end
      subject { described_class.for_parties }

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end

      it 'should contain 2 items' do
        expect(subject.length).to eql(2)
      end
    end
  end

  describe '.for_opportunities' do
    context 'when some definitions are returned' do
      before do
        stub_request(:get, /.*/).
          to_return(body: File.read('spec/support/custom_field_definitions.json'))
      end
      subject { described_class.for_opportunities }

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end

      it 'should contain 2 items' do
        expect(subject.length).to eql(2)
      end
    end
  end

  describe '.for_cases' do
    context 'when some definitions are returned' do
      before do
        stub_request(:get, /.*/).
          to_return(body: File.read('spec/support/custom_field_definitions.json'))
      end
      subject { described_class.for_cases }

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end

      it 'should contain 2 items' do
        expect(subject.length).to eql(2)
      end
    end
  end
end
