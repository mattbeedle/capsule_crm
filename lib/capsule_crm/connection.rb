module CapsuleCRM
  class Connection

    # Public: Send a GET request to CapsuleCRM API
    #
    # path    - The String path where the request should go
    # params  - The Hash of URL parameters
    #
    # Returns a Hash from the JSON response
    def self.get(path, params = {})
      preprocess_params(params)
      JSON.parse request(:get, path, params).body
    end

    def self.post(path, params = {})
      process_post_response request(:post, path, params)
    end

    def self.put(path, params)
      request(:put, path, params.to_json).success?
    end

    def self.delete(path)
      request(:delete, path, {}).success?
    end

    private

    def self.request(method, path, params)
      faraday.send(method, path, params) do |req|
        req.headers.update default_request_headers
      end.tap do |response|
        check_response_status(response)
      end
    end

    def self.check_response_status(response)
      if response.status == 401
        raise CapsuleCRM::Errors::Unauthorized.new(response)
      end
    end

    def self.preprocess_params(params)
      params.symbolize_keys!
      if params_contains_lastmodified(params)
        params[:lastmodified] = params[:lastmodified].strftime("%Y%m%dT%H%M%S")
      end
    end

    def self.params_contains_lastmodified(params)
      params.keys.include?(:lastmodified) &&
        params[:lastmodified].respond_to?(:strftime)
    end

    # TODO clean this shit up
    def self.process_post_response(response)
      if response.headers['Location'] &&
        match = response.headers['Location'].match(/\/(?<id>\d+)$/)
        { id: match[:id] }
      else
        true
      end
    end

    def self.default_request_headers
      { accept: 'application/json', content_type: 'application/json' }
    end

    def self.faraday
      Faraday.new("https://#{subdomain}.capsulecrm.com").tap do |connection|
        connection.basic_auth(CapsuleCRM.configuration.api_token, '')
        connection.request  :json
      end
    end

    def self.subdomain
      CapsuleCRM.configuration.subdomain
    end
  end
end
