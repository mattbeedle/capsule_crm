require 'spec_helper'

describe CapsuleCRM::Party do
  before { configure }

  it_behaves_like 'listable', File.read('spec/support/all_parties.json'), 3

  describe '.find' do
    context 'when finding an organization' do
      before do
        stub_request(:get, /\/api\/party\/#{id}$/).
          to_return(body: File.read('spec/support/organisation.json'))
      end

      subject { CapsuleCRM::Party.find(id) }

      let(:id) { rand(10) }

      it { expect(subject).to be_a(CapsuleCRM::Organization) }

      it { expect(subject.contacts).to be_a(CapsuleCRM::Contacts) }

      it 'should get the contact address street' do
        expect(subject.addresses.first.street).
          to eql('1600 Amphitheatre Parkway')
      end

      it 'should get the contact address city' do
        expect(subject.addresses.first.city).
          to eql('Mountain View')
      end

      it { expect(subject.addresses.first.state).to eql('CA') }

      it { expect(subject.addresses.first.zip).to eql('94043') }

      it 'should get the contact address country' do
        expect(subject.addresses.first.country).
          to eql('United States')
      end
    end

    context 'when finding a person' do
      before do
        stub_request(:get, /\/api\/party\/#{id}$/).
          to_return(body: File.read('spec/support/person.json'))
      end

      subject { CapsuleCRM::Party.find(id) }

      let(:id) { rand(10) }

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
end
