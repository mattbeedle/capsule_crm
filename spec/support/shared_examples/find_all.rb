shared_examples 'listable' do |path, file_name, item_count|
  before do
    stub_request(:get, /\/api#{path}$/).to_return(body: response)
  end
  subject { described_class.all }

  context "when there are some #{described_class.to_s.demodulize.downcase.pluralize}" do
    let(:response) { File.read("spec/support/all_#{file_name}.json") }

    it 'should be an array' do
      expect(subject).to be_a(Array)
    end

    it "should contain #{item_count} items" do
      expect(subject.length).to eql(item_count)
    end

    it "should only contain #{described_class} objects" do
      expect(subject.all? { |item| item.is_a?(described_class) }).to eql(true)
    end
  end

  context "when there are no #{described_class.to_s.demodulize.downcase.pluralize}" do
    let(:response) { File.read("spec/support/no_#{file_name}.json") }

    it 'should be an array' do
      expect(subject).to be_a(Array)
    end

    it "should contain 0 items" do
      expect(subject.length).to eql(0)
    end
  end
end
