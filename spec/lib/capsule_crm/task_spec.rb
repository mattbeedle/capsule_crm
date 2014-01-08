require 'spec_helper'

describe CapsuleCRM::Task do
  before do
    configure
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
    stub_request(:get, /\/api\/party\/1$/).
      to_return(body: File.read('spec/support/person.json'))
  end

  describe 'validations' do
    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:due_date) }
    it { should validate_presence_of(:due_date_time) }
  end

  describe '.find' do
    before do
      stub_request(:get, /\/api\/task\/2$/).
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

    it { subject.length.should eql(4) }

    it { subject.first.description.should eql('Meet with customer') }
  end

  describe '.create' do
    let(:location)  { 'https://sample.capsulecrm.com/api/task/59' }

    context 'when it is valid' do
      before do
        stub_request(:post, /\/api\/task$/).
          to_return(headers: { 'Location' => location })
      end

      subject { CapsuleCRM::Task.create Fabricate.attributes_for(:task) }

      it { should be_a(CapsuleCRM::Task) }

      it { should be_persisted }
    end

    context 'when it belongs to a party' do
      before do
        stub_request(:post, /\/api\/party\/#{party.id}\/task$/).
          to_return(headers: { 'Location' => location })
      end

      let(:party) { Fabricate.build(:person, id: 1) }

      subject do
        CapsuleCRM::Task.create(
          Fabricate.attributes_for(:task, party: party)
        )
      end

      it { should be_a(CapsuleCRM::Task) }

      it { should be_persisted }
    end

    context 'when it belongs to a opportunity' do
      before do
        stub_request(:post, /\/api\/opportunity\/#{opportunity.id}\/task$/).
          to_return(headers: { 'Location' => location })
      end

      let(:opportunity) { Fabricate.build(:opportunity, id: 2) }

      subject do
        CapsuleCRM::Task.create(
          Fabricate.attributes_for(:task, opportunity: opportunity)
        )
      end

      it { should be_a(CapsuleCRM::Task) }

      it { should be_persisted }
    end

    context 'when it belongs to a case' do
      before do
        stub_request(:post, /\/api\/kase\/#{kase.id}\/task$/).
          to_return(headers: { 'Location' => location })
      end

      let(:kase) { Fabricate.build(:case, id: 5) }

      subject do
        CapsuleCRM::Task.create(
          Fabricate.attributes_for(:task, case: kase)
        )
      end

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

  # Not really sure what to test here. CapsuleCRM API doesn't actually tell you
  # anything about a tasks state
  describe '#complete' do
    let(:task) { Fabricate.build(:task, id: 2) }

    subject { task.complete }

    before do
      stub_request(:post, /\/api\/task\/#{task.id}\/complete$/).
        to_return(status: 200)
      task.complete
    end

    it { should be_persisted }
  end

  describe '#reopen' do
    let(:task) { Fabricate.build(:task, id: 3) }

    subject { task.reopen }

    before do
      stub_request(:post, /\/api\/task\/#{task.id}\/reopen$/).
        to_return(status: 200)
    end

    it { should be_persisted }
  end

  describe '.categories' do
    subject { CapsuleCRM::Task.categories }

    before do
      stub_request(:get, /\/api\/task\/categories$/).
        to_return(body: File.read('spec/support/task_categories.json'))
    end

    it do
      expect(subject).to eql(%w(Call Email Follow-up Meeting Milestone Send))
    end
  end

  describe '#to_capsule_json' do
    let(:task) { Fabricate.build(:task) }

    subject { task.to_capsule_json }

    it { expect(subject.keys).to include('task') }

    it { expect(subject['task']['description']).to eql(task.description) }

    it { expect(subject['task']['dueDate']).to eql(task.due_date.to_s) }

    context 'when it has an owner' do
      let(:owner) { CapsuleCRM::User.new(username: 'matt.beedle') }

      before { task.owner = owner }

      it { expect(subject['task']['owner']).to eql(task.owner.username) }
    end
  end
end
