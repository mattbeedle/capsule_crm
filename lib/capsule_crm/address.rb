module CapsuleCRM
  class Address
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    include CapsuleCRM::CapsuleJsonable

    attribute :type
    attribute :street
    attribute :city
    attribute :state
    attribute :zip
    attribute :country
  end
end
