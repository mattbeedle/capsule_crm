module CapsuleCRM
  class CustomFieldDefinition
    include Virtus.model
    include CapsuleCRM::Serializable
    include CapsuleCRM::Gettable

    serializable_config do |config|
      config.collection_root = :customFieldDefinitions
      config.root = :customFieldDefinition
    end

    attribute :id, Integer
    attribute :tag, String
    attribute :label, String
    attribute :type, String
    attribute :options, String

    def self.for_parties
      normalizer.normalize_collection get('/api/party/customfield/definitions')
    end

    def self.for_opportunities
      normalizer.normalize_collection(
        get('/api/opportunity/customfield/definitions')
      )
    end

    def self.for_cases
      normalizer.normalize_collection get('/api/kase/customfield/definitions')
    end

    def self.normalizer
      @normalizer ||= CapsuleCRM::Normalizer.new(self)
    end
  end
end
