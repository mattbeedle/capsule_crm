require 'spec_helper'

describe CapsuleCRM::Connection do
  before { configure }

  describe '.get' do
    context 'when lastmodified is in the supplied params' do
      before do
        stub_request(:get, /\/api\/v1\/foo/).to_return(body: '{}')
        CapsuleCRM::Connection.
          get('/api/v1/foo', lastmodified: Time.new(2013, 10, 1, 13, 31, 56))
      end

      it 'should make sure that the lastmodified is formatted in YYYYMMDDTHHMMSS' do
        WebMock.should have_requested(
          :get, 'https://1234:@company.capsulecrm.com/api/v1/foo'
        ).with(query: { lastmodified: "20131001T133156" })
      end
    end

    context 'when the request is not authorized' do
      before do
        stub_request(:get, /\/api\/v1\/foo/).
          to_return(status: 401, body: '<html></html>')
      end
      subject { CapsuleCRM::Connection.get('/api/v1/food') }

      it 'should raise an Unauthorized error' do
        expect { CapsuleCRM::Connection.get('/api/v1/foo') }.
          to raise_error(CapsuleCRM::Errors::Unauthorized)
      end
    end
  end
end
