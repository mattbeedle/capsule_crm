module CapsuleCRM
  class Email
    include Virtus

    extend ActiveModel::Naming

    attribute :type
    attribute :email_address

    def to_capsule_json
      attributes.stringify_keys
    end
  end
end
