require 'spec_helper'

describe CapsuleCRM::Case do
  before { configure }

  it_behaves_like 'persistable', 'https://sample.capsulecrm.com/api/kase/1001', 1001 do
    let(:attributes) { Fabricate.attributes_for(:case).merge(party: party) }
    let(:party) { Fabricate.build(:person, id: Random.rand(1..10)) }
  end

  it_behaves_like 'deletable'

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
  end

  describe 'validations' do
    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:party) }
  end

  describe '._for_track' do
    let(:track) { CapsuleCRM::Track.new }

    it do
      expect { CapsuleCRM::Case._for_track(track) }.
        to raise_error(NotImplementedError)
    end
  end

  describe '#tasks' do
    let(:kase) { Fabricate.build(:case, id: 3) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { kase.tasks }

    it { should be_an(Array) }

    it { subject.length.should eql(1) }

    it { subject.first.detail.should eql('Go and get drunk') }
  end

  describe '.all' do
    before do
      stub_request(:get, 'https://1234:@company.capsulecrm.com/api/kase').
        to_return(body: File.read('spec/support/all_cases.json'))
    end

    subject { CapsuleCRM::Case.all }

    it { should be_a(Array) }

    it { subject.length.should eql(1) }

    it { subject.all? { |item| item.is_a?(CapsuleCRM::Case) }.should be_true }
  end

  describe '.find' do
    before do
      stub_request(:get, 'https://1234:@company.capsulecrm.com/api/kase/43').
        to_return(body: File.read('spec/support/case.json'))
    end

    subject { CapsuleCRM::Case.find(43) }

    it { should be_a(CapsuleCRM::Case) }

    it { subject.name.should eql('Consulting') }
  end

  describe '#to_capsule_json' do
    let(:kase) { CapsuleCRM::Case.new }
    subject { kase.to_capsule_json }

    it 'should have a root of "kase"' do
      expect(subject.keys.first).to eql('kase')
    end
  end
end
