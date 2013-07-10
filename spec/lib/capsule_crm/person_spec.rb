#encoding: utf-8

require 'spec_helper'

describe CapsuleCRM::Person do

  it_should_behave_like 'contactable'

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
  end

  before { configure }

  describe '#tasks' do
    let(:person) { Fabricate.build(:person, id: 1) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { person.tasks }

    it { should be_a(Array) }
  end

  describe '._for_organization' do
    context 'when there are many people for the organization' do
      pending
    end

    context 'when there is 1 person for the organization' do
      pending
    end

    context 'when there are no people for the organization' do
      pending
    end
  end

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
    context 'when the person is valid' do
      before do
        stub_request(:post, /.*/).to_return(headers: {
          'Location' => 'https://sample.capsulecrm.com/api/party/100'
        })
      end

      subject { CapsuleCRM::Person.create(first_name: 'Eric') }

      it { should be_a(CapsuleCRM::Person) }

      it { subject.id.should eql(100) }
    end

    context 'when the person is not valid' do
      subject { CapsuleCRM::Person.create }

      it { subject.errors.should_not be_blank }
    end
  end

  describe '.create!' do
    context 'when the person is valid' do
      before do
        stub_request(:post, /.*/).to_return(headers: {
          'Location' => 'https://sample.capsulecrm.com/api/party/101'
        })
      end

      subject { CapsuleCRM::Person.create(first_name: 'Eric') }

      it { should be_a(CapsuleCRM::Person) }

      it { should be_persisted }

      it { subject.id.should eql(101) }
    end

    context 'when the person is not valid' do
      it do
        expect { CapsuleCRM::Person.create! }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#update_attributes' do
    context 'when the person is valid' do
      before do
        stub_request(:put, /.*/).to_return(status: 200)
      end

      let(:person) { CapsuleCRM::Person.new(id: 1) }

      before { person.update_attributes first_name: 'James' }

      it { person.first_name.should eql('James') }

      it { person.id.should eql(1) }
    end

    context 'when the person is not valid' do
      let(:person) { CapsuleCRM::Person.new(id: 1) }

      before { person.update_attributes }

      it { person.should_not be_valid }

      it { person.errors.should_not be_blank }
    end
  end

  describe '#update_attributes!' do

    let(:person) { CapsuleCRM::Person.new(id: 1) }

    context 'when the person is valid' do
      before do
        stub_request(:put, /.*/).to_return(status: 200)
      end

      before { person.update_attributes first_name: 'James' }

      it { person.first_name.should eql('James') }

      it { person.id.should eql(1) }
    end

    context 'when the person is not valid' do
      it do
        expect { person.update_attributes! }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#save' do
    context 'when the person is a new record' do
      before do
        stub_request(:post, /.*/).to_return(headers: {
          'Location' => 'https://sample.capsulecrm.com/api/party/100'
        }, status: 200)
      end

      let(:person) { CapsuleCRM::Person.new(first_name: 'Eric') }

      before { person.save }

      it { person.first_name.should eql('Eric') }

      it { person.should be_persisted }
    end
  end

  describe '#save!' do
    context 'when the person is a new record' do
      context 'when the person is valid' do
        before do
          stub_request(:post, /.*/).to_return(headers: {
            'Location' => 'https://sample.capsulecrm.com/api/party/100',
          }, status: 200)
        end

        let(:person) { CapsuleCRM::Person.new(first_name: 'Eric') }

        before { person.save! }

        it { person.should be_persisted }
      end

      context 'when the person is not valid' do
        let(:person) { CapsuleCRM::Person.new }

        it do
          expect { person.save! }.
            to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end

    context 'when the person is not a new record' do
      context 'when the person is not valid' do

        let(:person) { CapsuleCRM::Person.new(id: 1) }

        it do
          expect { person.save! }.
            to raise_exception(CapsuleCRM::Errors::RecordInvalid)
        end
      end
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

  describe '#persisted?' do
    context 'when the person is persisted' do
      let(:person) { CapsuleCRM::Person.new(id: 1) }

      subject { person.persisted? }

      it { should be_true }
    end

    context 'when the person is not persisted' do
      let(:person) { CapsuleCRM::Person.new }

      subject { person.persisted? }

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

  describe '#to_capsule_json' do
    let(:address) do
      CapsuleCRM::Address.new(
        street: 'Oranienburgerstraße', city: 'Berlin', state: 'Berlin',
        zip: '10117', country: 'de'
      )
    end

    let(:email) do
      CapsuleCRM::Email.new(type: 'Work', email_address: 'matt@gmail.com')
    end

    let(:contacts) do
      CapsuleCRM::Contacts.new(addresses: [address], emails: [email])
    end

    let(:person) do
      CapsuleCRM::Person.new(
        first_name: 'Matt', last_name: 'Beedle',
        organisation_name: "Matt's Company", contacts: contacts
      )
    end

    let(:email_json) { subject['contacts']['email'].first }

    let(:address_json) { subject['contacts']['address'].first }

    subject { person.to_capsule_json['person'] }

    it { should have_key('firstName') }

    it { should have_key('lastName') }

    it { should have_key('organisationName') }

    it { should have_key('contacts') }

    it { address_json.should have_key('street') }

    it { address_json.should have_key('city') }

    it { address_json.should have_key('state') }

    it { address_json.should have_key('zip') }

    it { address_json.should have_key('country') }

    it { email_json.should have_key('type') }

    it { email_json.should have_key('emailAddress') }
  end
end
