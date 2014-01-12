module CapsuleCRM
  class Currency
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.attribute_to_assign = :code
    end

    attribute :code, String

    # Public: Retrieve a list of all currencies in Capsule
    #
    # Examples
    #
    # CapsuleCRM::Currency.all
    #
    # Returns an Array of CapsuleCRM::Currency objects
    def self.all
      CapsuleCRM::Normalizer.new(self).normalize_collection(
        CapsuleCRM::Connection.get('/api/currencies')
      )
    end
  end
end