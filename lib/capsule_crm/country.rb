module CapsuleCRM
  class Country
    include Virtus

    include CapsuleCRM::Serializable
    include CapsuleCRM::Persistable
    include CapsuleCRM::Querying::FindAll

    serializable_config do |config|
      config.attribute_to_assign = :name
    end

    attribute :name
  end
end