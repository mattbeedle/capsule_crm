module CapsuleCRM
  class Email
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    attribute :type
    attribute :email_address
  end
end
