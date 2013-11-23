module CapsuleCRM
  class Country
    include Virtus.model

    attribute :name

    # Public: Retrieve a list of countries from Capsule
    #
    # Examples
    #
    # CapsuleCRM::Country.all
    #
    # Returns an Array of CapsuleCRM::Country objects
    def self.all
      CapsuleCRM::Connection.
        get('/api/countries')['countries']['country'].map do |country_name|
        new name: country_name
      end
    end
  end
end