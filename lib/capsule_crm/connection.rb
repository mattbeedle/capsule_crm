module CapsuleCRM
  class Connection

    # Public: Send a GET request to CapsuleCRM API
    #
    # path    - The String path where the request should go
    # params  - The Hash of URL parameters
    #
    # Returns a Hash from the JSON response
    def self.get(path, params = {})
      response = faraday.get(path, params) do |req|
        req.headers.update default_request_headers
      end
      JSON.parse response.body
    end

    def self.post(path, params)
      response = faraday.post(path, params)
      id = response.headers['Location'].match(/\/(?<id>\d+)$/)[:id]
      { id: id }
    end

    def self.put(path, params)
      faraday.put(path, params)
    end

    def self.delete(path, params)
      JSON.parse faraday.delete(path, params).body
    end

    private

    def self.default_request_headers
      {
        'Accept' => 'application/json',
      }
    end

    def self.faraday
      Faraday.new("http://#{subdomain}.capsulecrm.com").tap do |connection|
        connection.basic_auth(CapsuleCRM.configuration.api_token, '')
      end
    end

    def self.subdomain
      CapsuleCRM.configuration.subdomain
    end
  end
end
