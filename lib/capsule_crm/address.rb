module CapsuleCRM
  class Address
    include Virtus.model
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    serializable_config do |config|
      config.include_root = false
    end

    attribute :type
    attribute :street
    attribute :city
    attribute :state
    attribute :zip
    attribute :country
  end
end
