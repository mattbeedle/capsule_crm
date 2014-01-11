module CapsuleCRM
  class Address
    include Virtus
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    self.serializable_options = {
      include_root: false
    }

    attribute :type
    attribute :street
    attribute :city
    attribute :state
    attribute :zip
    attribute :country
  end
end
