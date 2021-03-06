class CapsuleCRM::Party
  include Virtus.model

  include CapsuleCRM::Associations
  include CapsuleCRM::Inspector
  include CapsuleCRM::Querying::Findable
  include CapsuleCRM::Serializable
  include CapsuleCRM::Taggable

  serializable_config do |config|
    config.root = [:organisation, :person]
  end

  queryable_config do |config|
    config.plural = :party
  end

  has_many :histories
  has_many :tasks
  has_many :custom_fields, embedded: true
  has_many :cases
  has_many :opportunities

  private

  def self.child_classes
    { person: 'CapsuleCRM::Person', organisation: 'CapsuleCRM::Organization' }.
      stringify_keys
  end
end
