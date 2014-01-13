shared_examples 'listable' do |response, item_count|
  describe '.all' do
    subject { described_class.all }
    before do
      stub_request(:get, /\/api\/#{described_class.queryable_options.plural.to_s}$/).
        to_return(body: response)
    end

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
end
