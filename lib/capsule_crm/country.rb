module CapsuleCRM
  class Country
    include Virtus

    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.attribute_to_assign = :name
    end

    attribute :name

    # Public: Retrieve a list of countries from Capsule
    #
    # Examples
    #
    # CapsuleCRM::Country.all
    #
    # Returns an Array of CapsuleCRM::Country objects
    def self.all
      p CapsuleCRM::Normalizer.new(self).normalize_collection(
        CapsuleCRM::Connection.get('/api/countries')
      )
    end
  end
end