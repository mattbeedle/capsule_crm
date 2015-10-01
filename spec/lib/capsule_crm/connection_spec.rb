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
        expect(WebMock).to have_requested(
          :get, 'https://1234:@company.capsulecrm.com/api/v1/foo'
        ).with(query: { lastmodified: "20131001T133156" })
      end
    end

    context 'when the request is not authorized' do
      before do
        stub_request(:get, /\/api\/v1\/foo/).
          to_return(status: 401, body: '<html></html>')
      end
      subject { CapsuleCRM::Connection.get('/api/v1/foo') }

      it 'should raise an NotAuthorized error' do
        expect { subject }.to raise_error(CapsuleCRM::Errors::NotAuthorized)
      end
    end
  end

  describe '.post' do
    subject { CapsuleCRM::Connection.post('/foo', { bar: :baz }) }

    context 'when it is a success' do
      context 'when it returns a location header' do
        before do
          stub_request(:post, /.*/).to_return(
            status: 200, headers: { 'Location' => "http://foo.bar/#{id}" }
          )
        end
        let(:id) { Random.rand(1..100) }

        it 'should return the ID' do
          expect(subject).to eql({ id: id })
        end
      end

      context 'when it does not return a location header' do
        before do
          stub_request(:post, /.*/).to_return(status: 200, body: {}.to_json)
        end

        it 'should return true' do
          expect(subject).to eql(true)
        end
      end
    end

    context 'when the request is not authorized' do
      before do
        stub_request(:post, /.*/).to_return(status: 401, body: '<html></html>')
      end

      it 'should raise an NotAuthorized error' do
        expect { subject }.to raise_error(CapsuleCRM::Errors::NotAuthorized)
      end
    end
  end

  describe '.put' do
    subject { CapsuleCRM::Connection.put('/foo', { bar: :baz }) }

    context 'when it is a success' do
      before do
        stub_request(:put, /.*/).to_return(status: 200, body: {}.to_json)
      end

      it 'should return true' do
        expect(subject).to eql(true)
      end
    end

    context 'when it is not authorized' do
      before do
        stub_request(:put, /\.*/).to_return(status: 401)
      end

      it 'should raise an NotAuthorized error' do
        expect { subject }.to raise_error(CapsuleCRM::Errors::NotAuthorized)
      end
    end
  end

  describe '.delete' do
    subject { CapsuleCRM::Connection.delete('/foo') }

    context 'when it is a success' do
      before do
        stub_request(:delete, /.*/).to_return(status: 200)
      end

      it 'should return true' do
        expect(subject).to eql(true)
      end
    end

    context 'when it is not authorized' do
      before do
        stub_request(:delete, /.*/).to_return(status: 401)
      end

      it 'should raise an NotAuthorized error' do
        expect { subject }.to raise_error(CapsuleCRM::Errors::NotAuthorized)
      end
    end
  end
end
