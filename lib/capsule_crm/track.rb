module CapsuleCRM
  class Track
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Querying::FindAll
    include CapsuleCRM::Serializable

    attribute :id,            Integer
    attribute :description,   String
    attribute :capture_rule,  String

    has_many :opportunities
    has_many :cases

    validates :id, numericality: { allow_blank: true }
  end
end