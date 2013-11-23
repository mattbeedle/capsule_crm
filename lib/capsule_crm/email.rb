module CapsuleCRM
  class Email
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    include CapsuleCRM::CapsuleJsonable

    attribute :type
    attribute :email_address

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
