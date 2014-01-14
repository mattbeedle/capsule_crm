#encoding: utf-8

require 'spec_helper'

describe CapsuleCRM::Person do

  it_should_behave_like 'contactable'

  it_behaves_like 'persistable', 'https://sample.capsulecrm.com/api/person/34', 34 do
    let(:attributes) { Fabricate.attributes_for(:person) }
  end

  it_behaves_like 'deletable'

  it_behaves_like 'listable', '/party', 'parties', 2

  it_behaves_like 'findable', '/api/party/12', 12, 'person' do
    let(:attributes) do
      {
        first_name: 'Eric', last_name: 'Schmidt', job_title: 'Chairman',
        about: 'A comment here'
      }
    end

    it 'should get the email address' do
      expect(subject.emails.first.email_address).
        to eql('e.schmidt@google.com')
    end

    it 'should get the phone number' do
      expect(subject.phones.first.phone_number).to eql('+1 888 555555')
    end

    it 'should get the website' do
      expect(subject.websites.first.web_address).to eql('www.google.com')
    end
  end

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
  end

  before { configure }

  describe 'validations' do
    subject { described_class.new }

    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    context 'when the first name is set' do
      before { subject.first_name = Faker::Lorem.word }

      it { should_not validate_presence_of(:last_name) }
    end

    context 'when the last name is set' do
      before { subject.last_name = Faker::Lorem.word }

      it { should_not validate_presence_of(:first_name) }
    end
  end

  describe '#tasks' do
    let(:person) { Fabricate.build(:person, id: 1) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { person.tasks }

    it { should be_a(Array) }
  end

  describe '#custom_fields' do
    before do
      stub_request(:get, /\/api\/party\/#{person.id}\/customfields/).
        to_return(body: File.read('spec/support/no_customfields.json'))
    end
    let(:person) { Fabricate.build(:person, id: 1) }

    describe '#build' do
      before { person.custom_fields.build(label: 'test', text: 'bidule') }

      it 'should add a custom field' do
        expect(person.custom_fields.length).to eql(1)
      end
    end
  end

  describe '._for_organization' do
    context 'when there are many people for the organization' do
      before do
        stub_request(:get, /.*/).
          to_return(body: File.read('spec/support/all_people.json'))
      end
      subject { CapsuleCRM::Person._for_organization(1) }

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end

      it 'should contain 2 items' do
        expect(subject.length).to eql(2)
      end
    end

    context 'when there is 1 person for the organization' do
      before do
        stub_request(:get, /\/api\/party\/1\/people$/).
          to_return(body: File.read('spec/support/single_person.json'))
      end
      subject { CapsuleCRM::Person._for_organization(1) }

      it { should be_a(Array) }
    end

    context 'when there are no people for the organization' do
      before do
        stub_request(:get, /.*/).
          to_return(body: File.read('spec/support/no_parties.json'))
      end
      subject { CapsuleCRM::Person._for_organization(1) }

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end

      it 'should be empty' do
        expect(subject).to be_empty
      end
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
