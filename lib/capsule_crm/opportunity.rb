module CapsuleCRM
  class Opportunity
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Querying::Findable
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Persistence::Deletable
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.excluded_keys = [:track_id]
    end

    queryable_config do |config|
      config.plural = :opportunity
    end

    persistable_config do |config|
      config.create = lambda do |opportunity|
        path = "party/#{opportunity.party.try(:id)}/opportunity"
        path += "?trackId=#{opportunity.track_id}" if opportunity.track_id
        path
      end
    end

    attribute :id, Integer
    attribute :name, String
    attribute :description, String
    attribute :currency
    attribute :value, Float
    attribute :duration_basis
    attribute :duration, Integer
    attribute :milestone_id, Integer
    attribute :expected_close_date, DateTime
    attribute :actual_close_date, DateTime
    attribute :probability, Float

    attr_accessor :milestone, :owner

    validates :id, numericality: { allow_blank: true }
    validates :name, presence: true
    validates :party, presence: true
    validates :milestone, presence: true

    has_many :tasks, class_name: 'CapsuleCRM::Task', source: :opportunity

    belongs_to :party,     class_name: 'CapsuleCRM::Party'
    belongs_to :milestone, class_name: 'CapsuleCRM::Milestone'
    belongs_to :track,     class_name: 'CapsuleCRM::Track'

    def milestone=(milestone)
      if milestone.is_a?(String)
        milestone = CapsuleCRM::Milestone.find_by_name(milestone)
      end
      @milestone = milestone
      self.milestone_id = milestone.try(:id)
      self
    end

    def self._for_track(track)
      raise NotImplementedError.new("There is no way to find opportunities by trackId in the Capsule API right now")
    end

    # Public: Get all deleted opportunities since the specified date
    #
    # since - The Date to start checking for deleted opportunities
    #
    # Examples
    #
    # CapsuleCRM::Opportunity.deleted(1.week.ago)
    #
    # Returns a ResultsProxy of opportunities
    def self.deleted(since)
      CapsuleCRM::Normalizer.new(
        self, root: 'deletedOpportunity', collection_root: 'deletedOpportunities'
      ).normalize_collection(
        CapsuleCRM::Connection.get('/api/opportunity/deleted', since: since)
      )
    end
  end
end
