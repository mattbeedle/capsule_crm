module CapsuleCRM
  class Website
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON

    include CapsuleCRM::CapsuleJsonable

    attribute :type
    attribute :web_service
    attribute :web_address

    validates :web_service, :web_address, presence: true

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
