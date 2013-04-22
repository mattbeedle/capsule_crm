module CapsuleCRM
  class Address
    include Virtus

    include CapsuleCRM::Associations::BelongsTo

    extend ActiveModel::Naming

    attribute :type
    attribute :street
    attribute :city
    attribute :state
    attribute :zip
    attribute :country

    belongs_to :person
  end
end
