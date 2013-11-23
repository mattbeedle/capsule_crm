module CapsuleCRM
  class Currency
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :code, String

    # Public: Retrieve a list of all currencies in Capsule
    #
    # Examples
    #
    # CapsuleCRM::Currency.all
    #
    # Returns an Array of CapsuleCRM::Currency objects
    def self.all
      CapsuleCRM::Connection.
        get('/api/currencies')['currencies']['currency'].map do |currency_code|
        new code: currency_code
      end
    end
  end
end