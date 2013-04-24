module CapsuleCRM
  class Phone
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    include CapsuleCRM::CapsuleJsonable

    attribute :type
    attribute :phone_number
  end
end
