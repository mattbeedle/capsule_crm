class CapsuleCRM::Party
  include Virtus.model

  include CapsuleCRM::Attributes
  include CapsuleCRM::Taggable
  include CapsuleCRM::Associations::HasMany

  has_many :histories, class_name: 'CapsuleCRM::History', source: :party
  has_many :tasks, class_name: 'CapsuleCRM::Task', source: :party

  def self.all(options = {})
    init_collection(
      CapsuleCRM::Connection.get('/api/party', options)['parties']
    )
  end

  def self.find(id)
    attributes = CapsuleCRM::Connection.get("/api/party/#{id}")
    party_classes[attributes.keys.first].constantize.new(
      attributes[attributes.keys.first]
    )
  end

  private

  def self.init_collection(collection)
    CapsuleCRM::ResultsProxy.new(
      collection.map do |key, value|
        next unless %w(organisation person).include?(key)
        [collection[key]].flatten.map do |attrs|
          party_classes[key].constantize.new(attrs)
        end.flatten
      end.flatten
    )
  end

  def self.party_classes
    { person: 'CapsuleCRM::Person', organisation: 'CapsuleCRM::Organization' }.
      stringify_keys
  end
end
