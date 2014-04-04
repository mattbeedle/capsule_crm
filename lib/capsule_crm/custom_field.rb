module CapsuleCRM
  class CustomField
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.root            = 'customField'
      config.collection_root = 'customFields'
    end

    queryable_config do |config|
      config.plural = 'customfields'
    end

    attribute :id, Integer
    attribute :label, String
    attribute :date, DateTime
    attribute :tag, String
    attribute :boolean, Boolean
    attribute :text, String

    validates :id, numericality: { allow_blank: true }
    validates :label, presence: true

    belongs_to :party, serialize: false
    belongs_to :opportunity, serialize: false
    belongs_to :case, serialize: false

    class << self
      alias :_for_organization :_for_party
      alias :_for_person :_for_party
    end

    def parent
      party || opportunity || self.case
    end

    def destroy
      self.date, self.tag, self.boolean, self.text = nil, nil, nil, nil
      self.parent.custom_fields.save
    end
  end
end
