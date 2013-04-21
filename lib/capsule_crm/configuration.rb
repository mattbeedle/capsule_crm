class CapsuleCRM::Configuration

  attr_accessor :api_token, :logger, :subdomain

  def logger
    @logger || Logger.new(STDOUT)
  end
end
