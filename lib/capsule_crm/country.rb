module CapsuleCRM
  class Country
    include Virtus.model

    include CapsuleCRM::Serializable
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Querying::FindAll

    serializable_config do |config|
      config.attribute_to_assign = :name
    end

    attribute :name
  end
end