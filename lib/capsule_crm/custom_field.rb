module CapsuleCRM
  class CustomField
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :id, Integer
    attribute :label, String
    attribute :date, DateTime
    attribute :tag, String
    attribute :boolean, Boolean
    attribute :text, String

    validates :label, presence: true

    include CapsuleCRM::Associations
    belongs_to :party, class_name: 'CapsuleCRM::Party'


    def self._for_party(party_id)
      init_collection(
        CapsuleCRM::Connection.
          get("/api/party/#{party_id}/customfields")['customFields'].
          fetch('customField', nil)
      )
    end

    class << self
      alias :_for_organization :_for_party
      alias :_for_person :_for_party
    end


    def self.init_collection(collection)
      CapsuleCRM::ResultsProxy.new(
        [collection].flatten.delete_if(&:blank?).map { |item| new(item) }
      )
    end

    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
      self
    end

    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    def self.create!(attribute = {})
      new(attributes).tap(&:save)
    end

    def save
      if valid?
        update_record
      else
        false
      end
    end

    def save!
    end

    def destroy
    end

    def to_capsule_json
      {
        customFields: {
          customField: [CapsuleCRM::HashHelper.camelize_keys(
            {
              id: id,
              label: label,
              date: date,
              tag: tag,
              boolean: boolean,
              text: text,
            }.delete_if { |key, value| value.blank? }
          )]
        }
      }
    end

    private

    def update_record
      CapsuleCRM::Connection.post(
        "/api/party/#{party.id}/customfields", to_capsule_json
      )
    end
  end
end
