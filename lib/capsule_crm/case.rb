module CapsuleCRM
  class Case
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Persistence::Deletable
    include CapsuleCRM::Querying::Findable
    include CapsuleCRM::Serializable
    include CapsuleCRM::Taggable

    serializable_config do |config|
      config.collection_root = :kases
      config.root            = :kase
      config.excluded_keys   = [:track_id]
    end

    queryable_config do |config|
      config.plural   = :kase
      config.singular = :kase
    end

    persistable_config do |config|
      config.create = lambda do |kase|
        path = "party/#{kase.party.try(:id)}/kase"
        path += "?trackId=#{kase.track.id}" if kase.track
        path
      end
      config.update = lambda { |kase| "kase/#{kase.id}" }
      config.destroy = lambda { |kase| "kase/#{kase.id}" }
    end

    attribute :id, Integer
    attribute :name, String
    attribute :description, String
    attribute :status, String
    attribute :close_date, Date
    attribute :owner, String

    validates :id, numericality: { allow_blank: true }
    validates :name, presence: true
    validates :party, presence: true

    belongs_to :party
    belongs_to :track

    has_many :tasks
    has_many :histories
    has_many :custom_fields, embedded: true

    def self._for_track(track)
      raise NotImplementedError.new("There is no way to find cases by trackId in the Capsule API right now")
    end
  end
end
