module CapsuleCRM
  class Connection
    def self.get(path, params = {})
      new.get(path, params)
    end

    def get(path, params)
      preprocess_params(params)
      JSON.parse request(:get, path, params).body
    end

    def self.post(path, params = {})
      new.post(path, params)
    end

    def post(path, params)
      process_post_response request(:post, path, params.to_json)
    end

    def self.put(path, params = {})
      new.put(path, params)
    end

    def put(path, params)
      request(:put, path, params.to_json).success?
    end

    def self.delete(path)
      new.delete(path)
    end

    def delete(path)
      request(:delete, path).success?
    end

    private

    def request(method, path, params = {})
      log "CapsuleCRM: #{method.upcase} #{path} with #{params}"
      faraday.send(method, path, params) do |req|
        req.headers.update default_request_headers
      end.tap do |response|
        log "CapsuleCRM Response: #{response.body}"
      end
    end

    def log(string)
      CapsuleCRM.log string
    end

    def preprocess_params(params)
      params.symbolize_keys!
      if params_contains_lastmodified(params)
        params[:lastmodified] = params[:lastmodified].strftime("%Y%m%dT%H%M%S")
      end
    end

    def params_contains_lastmodified(params)
      params.keys.include?(:lastmodified) &&
        params[:lastmodified].respond_to?(:strftime)
    end

    def process_post_response(response)
      if response.headers['Location'] &&
        match = response.headers['Location'].match(/\/(?<id>\d+)$/)
        { id: match[:id].to_i }
      else
        true
      end
    end

    def default_request_headers
      { accept: 'application/json', content_type: 'application/json' }
    end

    def faraday
      @faraday ||= ::Faraday.new("https://#{host}").tap do |connection|
        connection.basic_auth(CapsuleCRM.configuration.api_token, '')
        connection.request  :json
        connection.use CapsuleCRM::Faraday::Middleware::RaiseError
      end
    end

    def host
      @host ||= "#{subdomain}.capsulecrm.com"
    end

    def subdomain
      @subdomain ||= CapsuleCRM.configuration.subdomain
    end
  end
end
