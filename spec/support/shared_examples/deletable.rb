shared_examples 'deletable' do
  subject { described_class.new(id: Random.rand(1..10)) }
  before do
    stub_request(:delete, /.*/).to_return(status: 200)
    subject.destroy
  end

  it 'should not be persisted' do
    expect(subject.persisted?).to eql(false)
  end

  it 'should not have ID' do
    expect(subject.id).to be_blank
  end
end
