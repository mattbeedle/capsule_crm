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

  describe '#attributes=' do
    let(:person) { CapsuleCRM::Person.new }

    before do
      person.attributes= { firstName: 'Matt', lastName: 'Beedle' }
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

      subject { CapsuleCRM::Person.create }

      it { should be_a(CapsuleCRM::Person) }

      it { subject.about.should eql('A comment here') }

      it { subject.first_name.should eql('Eric') }

      it { subject.last_name.should eql('Schmidt') }

      it { subject.organisation_name.should eql('Google Inc') }

      it { subject.job_title.should eql('Chairman') }
    end
  end

  describe '#update_attributes' do
    context 'when the person saves successfully' do
      before do
        stub_request(:put, /.*/).
          to_return(body: File.read('spec/support/update-person.json'))
      end

      let(:person) { CapsuleCRM::Person.new(id: 1) }

      before { person.update_attributes first_name: 'James' }

      it { person.first_name.should eql('James') }

      it { person.id.should eql(1) }
    end
  end

  describe '#save' do
    context 'when the person is a new record' do
      before do
        stub_request(:post, /.*/).
          to_return(body: File.read('spec/support/create-person.json'))
      end

      let(:person) { CapsuleCRM::Person.new }

      before { person.save }

      it { person.about.should eql('A comment here') }

      it { person.first_name.should eql('Eric') }

      it { person.last_name.should eql('Schmidt') }

      it { person.organisation_name.should eql('Google Inc') }

      it { person.job_title.should eql('Chairman') }
    end

    context 'when the person is not a new record' do
      before do
        stub_request(:put, /.*/).
          to_return(body: File.read('spec/support/update-person.json'))
      end

      let(:person) { CapsuleCRM::Person.new(id: 1) }

      before { person.save }

      it { person.first_name.should eql('James') }

      it { person.id.should eql(1) }
    end
  end

  describe '#new_record?' do
    context 'when the person is a new record' do
      let(:person) { CapsuleCRM::Person.new }

      subject { person.new_record? }

      it { should be_true }
    end

    context 'when the person is not a new record' do
      let(:person) { CapsuleCRM::Person.new(id: 1) }

      subject { person.new_record? }

      it { should be_false }
    end
  end

  describe '.init_collection' do
    subject do
      CapsuleCRM::Person.init_collection(
        JSON.parse(
          File.read('spec/support/all_parties.json')
        )['parties']['person']
      )
    end

    it { should be_a(Array) }

    it { subject.length.should eql(2) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Person) }.should be_true
    end
  end

  describe '#first_name_required?' do
    let(:person) { CapsuleCRM::Person.new }

    subject { person.send(:first_name_required?) }

    context 'when there is no last name' do
      it { should be_true }
    end

    context 'when there is a last name' do
      before { person.last_name = 'Beedle' }

      it { should be_false }
    end
  end

  describe '#last_name_required?' do
    let(:person) { CapsuleCRM::Person.new }

    subject { person.send(:last_name_required?) }

    context 'when there is no first name' do
      it { should be_true }
    end

    context 'when there is a first name' do
      before { person.first_name = 'Matt' }

      it { should be_false }
    end
  end
end
