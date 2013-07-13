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
    attribute :data_tag, String

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
        new_record? ? create_record : update_record
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
        customFields: CapsuleCRM::HashHelper.camelize_keys(
          {
          }.delete_if { |key, value| value.blank? }
        )
      }
    end

    private

    def create_record
      self.attributes = CapsuleCRM::Connection.post(
        "/api/#{belongs_to_api_name}/#{belongs_to_id}/customfields", to_capsule_json
      )
      self
    end

    def update_record
    end
  end
end
