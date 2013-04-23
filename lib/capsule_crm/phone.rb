module CapsuleCRM
  class Phone
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Serializers::JSON

    attribute :type
    attribute :phone_number
  end
end
