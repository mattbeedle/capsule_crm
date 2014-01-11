module CapsuleCRM
  class Phone
    include Virtus
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    self.serializable_options = {
      include_root: false
    }

    attribute :type
    attribute :phone_number

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
