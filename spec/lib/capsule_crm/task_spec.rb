require 'spec_helper'

describe CapsuleCRM::Task do
  before do
    configure
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
    stub_request(:get, /\/api\/party\/1$/).
      to_return(body: File.read('spec/support/person.json'))
  end

  it_behaves_like 'persistable', 'https://sample.capsulecrm.com/api/task/91', 91 do
    let(:attributes) { Fabricate.attributes_for(:task) }
  end

  it_behaves_like 'deletable'

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
