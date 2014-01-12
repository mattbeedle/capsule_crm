module CapsuleCRM
  class Currency
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Persistable
    include CapsuleCRM::Querying::FindAll
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.attribute_to_assign = :code
    end

    attribute :code, String
  end
end