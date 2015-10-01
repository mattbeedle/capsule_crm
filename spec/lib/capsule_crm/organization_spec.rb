# -*- coding: utf-8 -*-
require 'spec_helper'

describe CapsuleCRM::Organization do
  before { configure }

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
  end

  it_should_behave_like 'contactable'

  it_behaves_like 'persistable', 'https://sample.capsulecrm.com/api/organisation/13', 13 do
    let(:attributes) { Fabricate.attributes_for(:organization) }
  end

  it_behaves_like 'deletable'

  it_behaves_like 'listable', '/party', 'parties', 1

  it_behaves_like 'findable', '/api/party/10', 10, 'organisation' do
    let(:attributes) do
      { name: 'Google Inc', about: 'A comment here' }
    end

    it 'should get the contact address street' do
      expect(subject.addresses.first.street).
        to eql('1600 Amphitheatre Parkway')
    end

    it 'should get the contact address city' do
      expect(subject.addresses.first.city).
        to eql('Mountain View')
    end

    it 'should get the contact address state' do
      expect(subject.addresses.first.state).to eql('CA')
    end

    it 'should get the contact address zip' do
      expect(subject.addresses.first.zip).to eql('94043')
    end

    it 'should get the contact address country' do
      expect(subject.addresses.first.country).
        to eql('United States')
    end
  end

  describe '.first' do
    subject { described_class }

    it 'should raise a NotImplementedError' do
      expect { subject.first }.to raise_error(NotImplementedError)
    end
  end

  describe '#custom_fields' do
    before do
      stub_request(:get, /\/api\/party\/#{organization.id}\/customfields/).
        to_return(body: File.read('spec/support/no_customfields.json'))
    end
    let(:organization) { Fabricate.build(:organization, id: 1) }

    describe '#build' do
      before { organization.custom_fields.build(label: 'test', text: 'bidule') }

      it 'should add a new custom field to the organization' do
        expect(organization.custom_fields.length).to eql(1)
      end
    end
  end

  describe '#people' do
    let(:organization) { Fabricate.build(:organization, id: 1) }

    subject { organization.people }

    before do
      stub_request(
        :get,
        "https://1234:@company.capsulecrm.com/api/party/#{organization.id}/people"
      ).to_return(body: File.read('spec/support/all_people.json'))
    end

    it { is_expected.to be_a(Array) }

    it do
      result = subject.all? { |item| item.is_a?(CapsuleCRM::Person) }
      expect(result).to eql(true)
    end
  end

  describe '#tasks' do
    let(:organization) { Fabricate.build(:organization, id: 1) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { organization.tasks }

    it { is_expected.to be_a(Array) }
  end


  describe '#to_capsule_json' do
    let(:address) do
      CapsuleCRM::Address.new(
        street: 'Oranienburgerstraße', city: 'Berlin', state: 'Berlin',
        zip: '10117', country: 'de'
      )
    end
    let(:email) do
      CapsuleCRM::Email.new(type: 'Work', email_address: 'mattscompany@gmail.com')
    end
    let(:contacts) do
      CapsuleCRM::Contacts.new(addresses: [address], emails: [email])
    end
    let(:organization) do
      CapsuleCRM::Organization.new(
        name: "Matt's Company",
        contacts: contacts
      )
    end
    let(:email_json) { subject['contacts']['email'].first }
    let(:address_json) { subject['contacts']['address'].first }
    subject { organization.to_capsule_json['organisation'] }

    it { is_expected.to have_key('name') }
    it { is_expected.to have_key('contacts') }
    it { expect(address_json).to have_key('street') }
    it { expect(address_json).to have_key('city') }
    it { expect(address_json).to have_key('state') }
    it { expect(address_json).to have_key('zip') }
    it { expect(address_json).to have_key('country') }
    it { expect(email_json).to have_key('type') }
    it { expect(email_json).to have_key('emailAddress') }
  end
end
