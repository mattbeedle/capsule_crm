module CapsuleCRM
  class Email
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    include CapsuleCRM::CapsuleJsonable

    attribute :type
    attribute :email_address
  end
end
