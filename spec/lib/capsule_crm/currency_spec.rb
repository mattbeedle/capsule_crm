require 'spec_helper'

describe CapsuleCRM::Currency do
  before { configure }

  describe '.all' do
    before do
      stub_request(:get, /\/api\/currencies$/).
        to_return(body: File.read('spec/support/currencies.json'))
    end

    subject { CapsuleCRM::Currency.all }

    it { should be_a(Array) }

    it { subject.length.should eql(3) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Currency) }.should be_true
    end

    it { subject.first.code.should eql('AUD') }
  end
end
