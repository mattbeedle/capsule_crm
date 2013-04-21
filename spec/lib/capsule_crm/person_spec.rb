require 'spec_helper'

describe CapsuleCRM::Person do

  before { configure }

  describe '.all' do
    before do
      stub_request(:get, /\/api\/party$/).
        to_return(body: File.read('spec/support/all_parties.json'))
    end

    subject { CapsuleCRM::Person.all }

    it { should be_a(Array) }

    it { subject.length.should eql(2) }

    it 'should only contain people' do
      subject.all? { |item| item.is_a?(CapsuleCRM::Person) }.should be_true
    end
  end

  describe '.find' do
    before do
      stub_request(:get, /.*/).
        to_return(body: File.read('spec/support/person.json'))
    end

    subject { CapsuleCRM::Person.find(1) }

    it { should be_a(CapsuleCRM::Person) }

    it { subject.first_name.should eql('Eric') }

    it { subject.last_name.should eql('Schmidt') }
  end

  describe '#initialize' do
    let(:person) do
      CapsuleCRM::Person.new(firstName: 'Matt', lastName: 'Beedle')
    end

    it { person.first_name.should eql('Matt') }

    it { person.last_name.should eql('Beedle') }
  end

  describe '.create' do
    context 'when the person saves successfully' do
      before do
        stub_request(:post, /.*/).
          to_return(body: File.read('spec/support/create-person.json'))
      end
    end

    it { pending }
  end
end
