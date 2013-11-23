module CapsuleCRM
  class Phone
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    include CapsuleCRM::CapsuleJsonable

    attribute :type
    attribute :phone_number

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
