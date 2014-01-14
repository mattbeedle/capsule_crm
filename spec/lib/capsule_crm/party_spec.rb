require 'spec_helper'

describe CapsuleCRM::Party do
  before { configure }

  it_behaves_like 'listable', '/party', 'parties', 3

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
end
