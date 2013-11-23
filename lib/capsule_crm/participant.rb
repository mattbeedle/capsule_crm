module CapsuleCRM
  class Participant
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attribute :name,          String
    attribute :email_address,  String
    attribute :role,          String

    def self._for_history(history_id)
      CapsuleCRM::ResultsProxy.new([])
    end

    def to_capsule_json
      CapsuleCRM::HashHelper.camelize_keys(attributes.dup)
    end
  end
end
