require 'spec_helper'

describe CapsuleCRM::User do
  before { configure }

  describe '.all' do
    before do
      stub_request(:get, /\/api\/users$/).
        to_return(body: File.read('spec/support/all_users.json'))
    end

    subject { CapsuleCRM::User.all }

    it { should be_a(Array) }

    it { subject.length.should eql(2) }

    it { subject.all? { |item| item.is_a?(CapsuleCRM::User) }.should be_true }
  end
end
