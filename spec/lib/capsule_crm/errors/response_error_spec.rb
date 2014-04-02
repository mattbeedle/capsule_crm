require 'spec_helper'

describe CapsuleCRM::Errors::ResponseError do
  describe '#to_s' do
    let(:response) { double('Response', body: response_body.to_json) }
    let(:response_body) do
      { message: 'this is an error message from the server' }
    end
    let(:error) { CapsuleCRM::Errors::ResponseError.new(response) }

    subject { error.to_s }

    it 'should include the server error message' do
      expect(subject).to eql(response_body[:message])
    end
  end
end