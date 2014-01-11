module CapsuleCRM
  class CustomField
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Attributes
    include CapsuleCRM::Collection
    include CapsuleCRM::Serializable

    self.serializable_options = { root: 'customField' }

    attribute :id, Integer
    attribute :label, String
    attribute :date, DateTime
    attribute :tag, String
    attribute :boolean, Boolean
    attribute :text, String

    validates :id, numericality: { allow_blank: true }
    validates :label, presence: true

    belongs_to :party, class_name: 'CapsuleCRM::Party'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'
    belongs_to :kase, class_name: 'CapsuleCRM::Case'

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
      if valid?
        update_record
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    def destroy
    end

    private

    def parent
      self.class.belongs_to_associations.each do |association|
        return self.send(assocation) unless self.send(association).blank?
      end
    end

    def update_record
      CapsuleCRM::Connection.post(
        "/api/party/#{party.id}/customfields", to_capsule_json
      )
    end
  end
end
