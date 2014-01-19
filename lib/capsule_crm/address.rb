module CapsuleCRM
  class Address
    include Virtus.model
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    serializable_config do |config|
      config.include_root = false
      config.exclude_id   = false
    end

    attribute :id, Integer
    attribute :type, String
    attribute :street, String
    attribute :city, String
    attribute :state, String
    attribute :zip, String
    attribute :country, String
  end
end
