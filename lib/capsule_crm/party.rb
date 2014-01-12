class CapsuleCRM::Party
  include Virtus

  include CapsuleCRM::Associations
  include CapsuleCRM::Persistable
  include CapsuleCRM::Querying::Findable
  include CapsuleCRM::Serializable
  include CapsuleCRM::Taggable

  serializable_config do |config|
    config.root = [:organisation, :person]
  end

  persistable_config do |config|
    config.plural = :party
  end

  has_many :histories, class_name: 'CapsuleCRM::History', source: :party
  has_many :tasks, class_name: 'CapsuleCRM::Task', source: :party

  private

  def self.child_classes
    { person: 'CapsuleCRM::Person', organisation: 'CapsuleCRM::Organization' }.
      stringify_keys
  end
end
