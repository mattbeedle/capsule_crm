require 'spec_helper'

describe CapsuleCRM::Organization do
  before { configure }

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
end
