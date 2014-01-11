module CapsuleCRM
  class Website
    include Virtus
    include CapsuleCRM::Serializable

    extend  ActiveModel::Naming
    include ActiveModel::Validations

    self.serializable_options = {
      include_root: false
    }

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
