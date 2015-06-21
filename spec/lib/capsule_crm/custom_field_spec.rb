require 'spec_helper'

describe CapsuleCRM::CustomField do
  before { configure }

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
    stub_request(:get, /\/api\/opportunity\/milestones$/).
      to_return(body: File.read('spec/support/all_milestones.json'))
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
        subject.all? { |item| item.is_a?(CapsuleCRM::CustomField) }.
          should eql(true)
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

  describe '#to_capsule_json' do
    let(:custom_field) { Fabricate.build(:custom_field) }
    subject { custom_field.to_capsule_json }

    it 'should be a hash' do
      expect(subject).to be_a(Hash)
    end

    it 'should have a root element of "customField"' do
      expect(subject.keys.first).to eql('customField')
    end
  end

  describe '#destroy' do
    let(:custom_field) { Fabricate.build(:custom_field, party: person) }
    let(:person) { Fabricate.build(:person, id: Random.rand(1..10)) }

    def stub_requests
      stub_request(
        :get,
        [
          'https://1234:@company.capsulecrm.com/api/party/',
          person.id,
          '/customfields'
        ].join
      ).to_return(body: File.read('spec/support/no_customfields.json'))
      # note, this test still passes although completely different data is being
      # returned from this stub. The data returned should overwrite the
      # association data
      stub_request(
        :put, [
          'https://1234:@company.capsulecrm.com/api/party/',
          person.id,
          '/customfields'
        ].join
      ).to_return(body: File.read('spec/support/put_customfields.json'))
    end

    before do
      stub_requests
      person.custom_fields << custom_field
      custom_field.destroy
    end

    it 'should remove the custom field from the parent association' do
      expect(person.custom_fields).not_to include(custom_field)
    end
  end
end
