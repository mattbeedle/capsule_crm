module CapsuleCRM
  class Address
    include Virtus

    extend ActiveModel::Naming

    attribute :type
    attribute :street
    attribute :city
    attribute :state
    attribute :zip
    attribute :country

    def to_capsule_json
      attributes.stringify_keys
    end
  end
end
