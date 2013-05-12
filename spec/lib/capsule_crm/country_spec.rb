require 'spec_helper'

describe CapsuleCRM::Country do
  before { configure }

  describe '.all' do
    before do
      stub_request(:get, /\/api\/countries$/).
        to_return(body: File.read('spec/support/countries.json'))
    end

    subject { CapsuleCRM::Country.all }

    it { should be_a(Array) }

    it { subject.count.should eql(2) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Country) }.should be_true
    end
  end
end
