module CapsuleCRM
  class Email
    include Virtus
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    self.serializable_options = {
      include_root: false
    }

    attribute :type
    attribute :email_address

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
