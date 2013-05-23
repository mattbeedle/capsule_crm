require 'spec_helper'

describe CapsuleCRM::Task do
  before { configure }

  describe '.find' do
    before do
      stub_request(:get, /\/api\/tasks\/2$/).
        to_return(body: File.read('spec/support/task.json'))
      stub_request(:get, /\/api\/users$/).
        to_return(body: File.read('spec/support/all_users.json'))
      stub_request(:get, /\/api\/party\/1$/).
        to_return(body: File.read('spec/support/person.json'))
    end

    subject { CapsuleCRM::Task.find(2) }

    it { should be_a(CapsuleCRM::Task) }

    it { subject.due_date.should_not be_blank }

    it { subject.category.should eql('Meeting') }

    it { subject.description.should eql('Meet with customer') }

    it { subject.detail.should eql('Meeting at Coffee shop') }

    it { subject.owner.should be_a(CapsuleCRM::User) }

    it { subject.party.should be_a(CapsuleCRM::Person) }
  end
end
