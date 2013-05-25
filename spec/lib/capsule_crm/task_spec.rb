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
    context 'when it is valid' do
      before do
        location = 'https://sample.capsulecrm.com/api/task/59'
        stub_request(:post, /\/api\/task$/).
          to_return(headers: { 'Location' => location })
      end

      subject { CapsuleCRM::Task.create! Fabricate.attributes_for(:task) }

      it { should be_a(CapsuleCRM::Task) }

      it { should be_persisted }
    end

    context 'when it is not valid' do
      subject { CapsuleCRM::Task.create! }

      it do
        expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#save' do
    let(:task) { Fabricate.build(:task) }

    context 'when it is a new record' do
      before do
        location = 'https://sample.capsulecrm.com/api/task/59'
        stub_request(:post, /\/api\/task$/).
          to_return(headers: { 'Location' => location })
      end

      subject { task.save }

      it { subject.id.should eql(59) }

      it { should be_persisted }
    end

    context 'when it is an existing record' do
      before do
        task.id = 12
        stub_request(:put, /\/api\/task\/12$/).to_return(status: 200)
      end

      subject { task.save }

      it { should be_persisted }
    end

    context 'when it is invalid' do
      it { subject.save.should be_false }
    end
  end

  describe '#save!' do
    let(:task) { Fabricate.build(:task) }

    context 'when it is a new record' do
      before do
        location = 'https://sample.capsulecrm.com/api/task/59'
        stub_request(:post, /\/api\/task$/).
          to_return(headers: { 'Location' => location })
      end

      subject { task.save! }

      it { subject.id.should eql(59) }

      it { should be_persisted }
    end

    context 'when it is an existing record' do
      before do
        task.id = 12
        stub_request(:put, /\/api\/task\/12$/).to_return(status: 200)
      end

      subject { task.save! }

      it { should be_persisted }
    end

    context 'when it is invalid' do
      it do
        expect { subject.save! }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#update_attributes' do
    context 'when it is valid' do
      let(:task) { Fabricate.build(:task, id: 1) }

      subject { task.update_attributes description: Faker::Lorem.sentence }

      before { stub_request(:put, /\/api\/task\/1$/).to_return(status: 200) }

      it { should be_persisted }
    end

    context 'when it is not valid' do
      let(:task) { CapsuleCRM::Task.new(id: 1) }

      subject { task.update_attributes }

      it { should be_false }
    end
  end

  describe '#update_attributes!' do
    context 'when it is valid' do
      let(:task) { Fabricate.build(:task, id: 1) }

      subject { task.update_attributes! description: Faker::Lorem.sentence }

      before { stub_request(:put, /\/api\/task\/1$/).to_return(status: 200) }

      it { should be_persisted }
    end

    context 'when it is not valid' do
      let(:task) { CapsuleCRM::Task.new(id: 1) }

      subject { task.update_attributes! }

      it do
        expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#destroy' do
    subject { Fabricate.build(:task, id: 1) }

    before do
      stub_request(:delete, /\/api\/task\/1$/).to_return(status: 200)
      subject.destroy
    end

    it { should_not be_persisted }
  end

  describe '#complete' do
    pending
  end

  describe '#re_open' do
    pending
  end

  describe '.categories' do
    pending
  end

  describe '#to_capsule_json' do
    pending
  end
end
