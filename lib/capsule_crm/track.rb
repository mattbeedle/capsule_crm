module CapsuleCRM
  class Track
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Attributes
    include CapsuleCRM::Collection
    include CapsuleCRM::Serializable

    attribute :id,            Integer
    attribute :description,   String
    attribute :capture_rule,  String

    has_many :opportunities, class_name: 'CapsuleCRM::Opportunity'
    has_many :cases, class_name: 'CapsuleCRM::Case'

    validates :id, numericality: { allow_blank: true }

    def self.all
      CapsuleCRM::Serializer.normalize_collection(
        self, CapsuleCRM::Connection.get('/api/tracks')
      )
    end
  end
end