shared_examples 'findable' do |path, id, file_name|
  let(:response) { File.read("spec/support/#{file_name}.json") }
  let(:url) { "https://1234:@company.capsulecrm.com#{path}" }
  before do
    stub_request(:get, url).to_return(body: response)
  end

  subject { described_class.find(id) }

  it "should be a #{described_class}" do
    expect(subject).to be_a(described_class)
  end

  it 'should populate the attributes from the response' do
    attributes.each do |key, value|
      expect(subject.send(key)).to eql(value)
    end
  end

  it "should return an instance of #{described_class}" do
    expect(subject).to be_a(described_class)
  end
end