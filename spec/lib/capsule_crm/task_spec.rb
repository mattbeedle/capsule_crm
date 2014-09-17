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

  it_behaves_like 'listable', '/tasks', 'tasks', 4

  it_behaves_like 'findable', '/api/task/2', 2, 'task' do
    let(:attributes) do
      {
        category: 'Meeting', description: 'Meet with customer',
        detail: 'Meeting at Coffee shop'
      }
    end

    it 'should populate the due date' do
      expect(subject.due_date).not_to be_blank
    end

    it 'should populate the owner' do
      expect(subject.owner).to be_a(CapsuleCRM::User)
    end

    it 'should populate the party' do
      expect(subject.party).to be_a(CapsuleCRM::Person)
    end
  end

  describe 'validations' do
    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:due_date) }
    it { should validate_presence_of(:due_date_time) }
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

  describe '#to_capsule_json' do
    let(:task) { Fabricate.build(:task) }

    subject { task.to_capsule_json }

    it { expect(subject.keys).to include('task') }
    it { expect(subject['task']['description']).to eql(task.description) }
    it { expect(subject['task']['dueDate']).to eql(task.due_date.to_s) }
    it { expect(subject['task']['category']).to eql(task.category) }

    context 'when it has an owner' do
      let(:owner) { CapsuleCRM::User.new(username: 'matt.beedle') }
      before { task.owner = owner }

      it { expect(subject['task']['owner']).to eql(task.owner.username) }
    end
  end
end
