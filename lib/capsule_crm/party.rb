class CapsuleCRM::Party
  include Virtus

  include CapsuleCRM::Associations
  include CapsuleCRM::Attributes
  include CapsuleCRM::Serializable
  include CapsuleCRM::Taggable

  serializable_config do |config|
    config.root = [:organisation, :person]
  end

  has_many :histories, class_name: 'CapsuleCRM::History', source: :party
  has_many :tasks, class_name: 'CapsuleCRM::Task', source: :party

  def self.all(options = {})
    CapsuleCRM::Normalizer.new(self).normalize_collection(
      CapsuleCRM::Connection.get('/api/party', options)
    )
  end

  def self.find(id)
    from_capsule_json CapsuleCRM::Connection.get("/api/party/#{id}")
  end

  private

  def self.child_classes
    { person: 'CapsuleCRM::Person', organisation: 'CapsuleCRM::Organization' }.
      stringify_keys
  end
end
