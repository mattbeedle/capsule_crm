# encoding: utf-8

require 'spec_helper'

describe CapsuleCRM::Contacts do

  let(:address) do
    CapsuleCRM::Address.new(
      street: 'Oranienburgerstraße', city: 'Berlin', state: 'Berlin',
      zip: '10117', country: 'Germany', type: 'Office'
    )
  end

  let(:email) do
    CapsuleCRM::Email.new(email_address: 'matt@gmail.com', type: 'Work')
  end

  let(:phone) do
    CapsuleCRM::Phone.new(phone_number: '1234', type: 'Work')
  end

  let(:website) do
    CapsuleCRM::Website.new(
      type: 'Work', web_service: 'URL', web_address: 'http://somewhere.com'
    )
  end

  describe '#emails=' do
    context 'when a hash is supplied' do
      let(:contacts) { CapsuleCRM::Contacts.new }
      let(:email_attributes) do
        { email_address: 'matt@gmail.com', type: 'Work' }
      end
      before { contacts.emails = email_attributes }
      subject { contacts.emails }

      it 'should create an email from the attributes' do
        expect(subject.first).to be_a(CapsuleCRM::Email)
      end

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end
    end
  end

  describe '#initialize' do
    context 'when addresses supplied' do
      subject { CapsuleCRM::Contacts.new(addresses: [address]) }

      it { subject.addresses.should_not be_blank }

      it do
        subject.addresses.
          all? { |address| address.is_a?(CapsuleCRM::Address) }.should be_true
      end
    end

    context 'when emails supplied' do
      subject { CapsuleCRM::Contacts.new(emails: [email]) }

      it { subject.emails.should_not be_blank }

      it do
        subject.emails.
          all? { |email| email.is_a?(CapsuleCRM::Email) }.should be_true
      end
    end

    context 'when phone numbers are supplied' do
      subject { CapsuleCRM::Contacts.new(phones: [phone]) }

      it { subject.phones.should_not be_blank }

      it do
        subject.phones.
          all? { |phone| phone.is_a?(CapsuleCRM::Phone) }.should be_true
      end
    end

    context 'when websites are supplied' do
      subject { CapsuleCRM::Contacts.new(websites: [website]) }

      it { subject.websites.should_not be_blank }

      it do
        subject.websites.
          all? { |website| website.is_a?(CapsuleCRM::Website) }.should be_true
      end
    end
  end
end
