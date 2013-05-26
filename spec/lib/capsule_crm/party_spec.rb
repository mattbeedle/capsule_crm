require 'spec_helper'

describe CapsuleCRM::Party do
  before { configure }

  describe '.find' do
    pending
  end

  describe '.all' do
    before do
      stub_request(:get, /\/api\/party$/).
        to_return(body: File.read('spec/support/all_parties.json'))
    end

    subject { CapsuleCRM::Party.all }

    it { subject.length.should eql(3) }

    it { subject.first.should be_a(CapsuleCRM::Organization) }

    it { subject.last.should be_a(CapsuleCRM::Person) }
  end
end
