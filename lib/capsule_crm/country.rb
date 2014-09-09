module CapsuleCRM
  class Country
    include Virtus.model

    include CapsuleCRM::Inspector
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Querying::FindAll
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.attribute_to_assign = :name
    end

    attribute :name
  end
end