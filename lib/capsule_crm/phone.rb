module CapsuleCRM
  class Phone
    include Virtus.model
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    serializable_config do |config|
      config.include_root = false
    end

    attribute :type
    attribute :phone_number

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
