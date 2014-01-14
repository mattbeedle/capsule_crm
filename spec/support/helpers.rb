module Helpers
  def configure
    CapsuleCRM.configure do |c|
      c.api_token       = '1234'
      c.subdomain       = 'company'
      c.perform_logging = false
    end
  end
end
