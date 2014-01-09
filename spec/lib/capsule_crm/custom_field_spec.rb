require 'spec_helper'

describe CapsuleCRM::CustomField do
  before { configure }

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
    stub_request(:get, /\/api\/opportunity\/milestones$/).
      to_return(body: File.read('spec/support/milestones.json'))
  end

  describe 'validations' do
    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:label) }
  end

  describe '._for_party' do
    let(:party) { Fabricate.build(:organization, id: 1) }
    subject { CapsuleCRM::CustomField._for_party(party.id) }

    context 'when there are some custom fields' do
      before do
        stub_request(:get, /\/api\/party\/#{party.id}\/customfields$/).
          to_return(body: File.read('spec/support/all_customfields.json'))
      end

      it { should be_an(Array) }
      it do
        subject.all? { |item| item.is_a?(CapsuleCRM::CustomField) }.should be_true
      end
    end

    context 'when there are no custom fields' do
      before do
        stub_request(:get, /\/api\/party\/#{party.id}\/customfields$/).
          to_return(body: File.read('spec/support/no_customfields.json'))
      end

      it { should be_blank }
    end
  end

  describe '.create' do
    context 'when it belongs to a party' do
      let(:organization) { Fabricate.build(:organization, id: 1) }
      let(:location) do
        'https://sample.capsulecrm.com/api/party/#{organization.id}/customfields'
      end
      subject do
        CapsuleCRM::CustomField.create(
          id: 100, tag: 'The tag', label: 'A field', text: 'Some text',
          date: Date.today, boolean: true, party: organization
        )
      end
      before do
        stub_request(:post, /\/api\/party\/#{organization.id}\/customfields$/).
          to_return(headers: { 'Location' => location})
      end

      it { expect(subject.id).to eql(100) }
    end
  end

  describe '#to_capsule_json' do
    let(:custom_field) { Fabricate.build(:custom_field) }
    subject { custom_field.to_capsule_json }

    it 'should be a hash' do
      expect(subject).to be_a(Hash)
    end

    it 'should have a root element of "customField"' do
      expect(subject.keys.first).to eql('customFields')
    end

    it 'should have an element named "customField"' do
      expect(subject['customFields'].keys.first).to eql('customField')
    end
  end
end
