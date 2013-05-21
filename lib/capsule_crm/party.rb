class CapsuleCRM::Party
  include CapsuleCRM::Taggable

  include CapsuleCRM::Associations::HasMany

  has_many :histories, class_name: 'CapsuleCRM::History'

  def self.all(options = {})
    attributes = CapsuleCRM::Connection.get('/api/party', options)
    init_collection(
      attributes['parties'].fetch('person', 'organisation')
    )
  end

  def self.find(id)
    attributes = CapsuleCRM::Connection.get("/api/party/#{id}")
    party_classes[attributes.keys.first].constantize.new(
      attributes[attributes.keys.first]
    )
  end

  private

  def self.party_classes
    {
      person:       'CapsuleCRM::Person',
      organisation: 'CapsuleCRM::Organization'
    }.stringify_keys
  end
end
