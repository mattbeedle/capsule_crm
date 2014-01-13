class CapsuleCRM::Configuration

  attr_accessor :api_token, :logger, :subdomain, :perform_logging

  def logger
    @logger || Logger.new(STDOUT)
  end
end
