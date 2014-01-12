module CapsuleCRM
  class CustomField
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.root = 'customField'
      config.collection_root = 'customFields'
    end

    attribute :id, Integer
    attribute :label, String
    attribute :date, DateTime
    attribute :tag, String
    attribute :boolean, Boolean
    attribute :text, String

    validates :id, numericality: { allow_blank: true }
    validates :label, presence: true

    belongs_to :party, class_name: 'CapsuleCRM::Party'

    def self._for_party(party_id)
      CapsuleCRM::Normalizer.new(self).normalize_collection(
        CapsuleCRM::Connection.
          get("/api/party/#{party_id}/customfields")
      )
    end

    class << self
      alias :_for_organization :_for_party
      alias :_for_person :_for_party
    end
  end
end
