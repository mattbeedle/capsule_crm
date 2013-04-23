module CapsuleCRM
  class Address
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    attribute :type
    attribute :street
    attribute :city
    attribute :state
    attribute :zip
    attribute :country
  end
end
