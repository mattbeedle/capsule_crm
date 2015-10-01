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
    let(:contacts) { CapsuleCRM::Contacts.new }
    before { contacts.emails = email_attributes }
    subject { contacts.emails }

    context 'when a hash is supplied' do
      let(:email_attributes) do
        { email_address: 'matt@gmail.com', type: 'Work' }
      end

      it 'should create an email from the attributes' do
        expect(subject.first).to be_a(CapsuleCRM::Email)
      end

      it 'should be an array' do
        expect(subject).to be_a(Array)
      end
    end

    context 'when an array is supplied' do
      context 'when the array contains hashes' do
        let(:email_attributes) do
          [{ email_address: Faker::Internet.email, type: 'Work' }]
        end

        it 'should create an email from the attributes' do
          expect(subject.first).to be_a(CapsuleCRM::Email)
        end

        it 'should be an array' do
          expect(subject).to be_a(Array)
        end
      end

      context 'when the array contains emails' do
        let(:email) do
          CapsuleCRM::Email.
            new(email_address: Faker::Internet.email, type: 'Work')
        end
        let(:email_attributes) { [email] }

        it 'should set the emails from the supplied array' do
          expect(subject).to eql(email_attributes)
        end
      end
    end
  end

  describe '#initialize' do
    context 'when addresses supplied' do
      subject { CapsuleCRM::Contacts.new(addresses: [address]) }

      it { expect(subject.addresses).not_to be_blank }

      it do
        result = subject.addresses.
          all? { |address| address.is_a?(CapsuleCRM::Address) }
        expect(result).to eql(true)
      end
    end

    context 'when emails supplied' do
      subject { CapsuleCRM::Contacts.new(emails: [email]) }

      it { expect(subject.emails).not_to be_blank }

      it do
        result = subject.emails.
          all? { |email| email.is_a?(CapsuleCRM::Email) }
        expect(result).to eql(true)
      end
    end

    context 'when phone numbers are supplied' do
      subject { CapsuleCRM::Contacts.new(phones: [phone]) }

      it { expect(subject.phones).not_to be_blank }

      it do
        result = subject.phones.
          all? { |phone| phone.is_a?(CapsuleCRM::Phone) }
        expect(result).to eql(true)
      end
    end

    context 'when websites are supplied' do
      subject { CapsuleCRM::Contacts.new(websites: [website]) }

      it { expect(subject.websites).not_to be_blank }

      it do
        result = subject.websites.
          all? { |website| website.is_a?(CapsuleCRM::Website) }
        expect(result).to eql(true)
      end
    end
  end
end
