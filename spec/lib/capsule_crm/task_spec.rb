require 'spec_helper'

describe CapsuleCRM::Task do
  before do
    configure
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
    stub_request(:get, /\/api\/party\/1$/).
      to_return(body: File.read('spec/support/person.json'))
  end

  it { should validate_presence_of(:description) }

  describe '.find' do
    before do
      stub_request(:get, /\/api\/tasks\/2$/).
        to_return(body: File.read('spec/support/task.json'))
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

  describe '.all' do
    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { CapsuleCRM::Task.all }

    it { should be_a(Array) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Task) }.should be_true
    end

    it { subject.length.should eql(1) }

    it { subject.first.description.should eql('Meet with customer') }
  end

  describe '.create' do
    context 'when it is valid' do
      before do
        location = 'https://sample.capsulecrm.com/api/task/59'
        stub_request(:post, /\/api\/task$/).
          to_return(headers: { 'Location' => location })
      end

      subject { CapsuleCRM::Task.create Fabricate.attributes_for(:task) }

      it { should be_a(CapsuleCRM::Task) }

      it { should be_persisted }
    end

    context 'when it is not valid' do
      subject { CapsuleCRM::Task.create }

      it { should_not be_persisted }
    end
  end

  describe '.create!' do
    pending
  end
end
