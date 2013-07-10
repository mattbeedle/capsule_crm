# -*- coding: utf-8 -*-
require 'spec_helper'

describe CapsuleCRM::Organization do
  before { configure }

  it_should_behave_like 'contactable'

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
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

    it { should be_a(Array) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Person) }.should be_true
    end
  end

  describe '#tasks' do
    let(:organization) { Fabricate.build(:organization, id: 1) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { organization.tasks }

    it { should be_a(Array) }
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

    it { should have_key('name') }

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
