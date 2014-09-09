module CapsuleCRM
  class Tag
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Inspector

    attribute :name

    validates :name, presence: true
  end
end