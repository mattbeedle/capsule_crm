module CapsuleCRM
  class TaskCategory
    include Virtus.model

    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Inspector
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Querying::FindAll
    include CapsuleCRM::Serializable

    queryable_config do |config|
      config.plural   = 'task/categories'
    end

    serializable_config do |config|
      config.collection_root     = 'taskCategories'
      config.root                = 'taskCategory'
      config.attribute_to_assign = :name
    end

    attribute :name

    validates :name, presence: true

    has_many :tasks, source: :category

    def id; name; end
  end
end
