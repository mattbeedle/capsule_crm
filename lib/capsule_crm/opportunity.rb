module CapsuleCRM
  class Opportunity
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Persistable
    include CapsuleCRM::Querying::Findable
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.excluded_keys = [:track_id]
    end

    persistable_config do |config|
      config.plural = :opportunity
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

    # Public: Create a new opportunity in capsulecrm
    #
    # attributes  - The Hash of opportunity attributes (default: {}):
    #               :name                 - The String opportunity name
    #               :description          - The String opportunity description
    #               :currency             - The String currency code
    #               :value                - The Float opportunity (financial) value
    #               :duration_basis       - The String duration basis
    #               :duration             - The Integer duration (for opportunities
    #               with a repeating (not FIXED) duratin basis
    #               :party_id             - The Integer party id
    #               :milestone_id         - The Integer milestone id
    #               :expected_close_date  - The DateTime when the opportunity
    #               is expected to be closed
    #               :actual_close_date    - The DateTime when the opportunity
    #               was actually closed
    #               :probability          - The Float probability that this
    #               opportunity will be won
    #
    # Examples
    #
    # CapsuleCRM::opportunity.create(name: 'Test', milestone_id: 1)
    #
    # Returns a CapsuleCRM::opportunity
    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    # Public: Create a new opportunity in capsulecrm and raise a
    # CapsuleCRM::Errors::InvalidRecord error if not possible
    #
    # attributes  - The Hash of opportunity attributes (default: {}):
    #               :name                 - The String opportunity name
    #               :description          - The String opportunity description
    #               :currency             - The String currency code
    #               :value                - The Float opportunity (financial) value
    #               :duration_basis       - The String duration basis
    #               :duration             - The Integer duration (for opportunities
    #               with a repeating (not FIXED) duratin basis
    #               :party_id             - The Integer party id
    #               :milestone_id         - The Integer milestone id
    #               :expected_close_date  - The DateTime when the opportunity
    #               is expected to be closed
    #               :actual_close_date    - The DateTime when the opportunity
    #               was actually closed
    #               :probability          - The Float probability that this
    #               opportunity will be won
    #
    # Examples
    #
    # CapsuleCRM::opportunity.create!(name: 'Test', milestone_id: 1)
    #
    # Returns a CapsuleCRM
    def self.create!(attributes = {})
      new(attributes).tap(&:save!)
    end

    # Public: If the opportunity already exists in capsule then update them,
    # otherwise create a new opportunity
    #
    # Examples
    #
    # opportunity = CapsuleCRM::Opportunity.new(name: 'Test', milestone_id: 1)
    # opportunity.save
    #
    # opportunity = CapsuleCRM::Opportunity.find(1)
    # opportunity.name = 'Another Test'
    # opportunity.save
    #
    # Returns a CapsuleCRM::opportunity
    def save
      if valid?
        new_record? ? create_record : update_record
      else
        false
      end
    end

    # Public: If the opportunity already exists in capsule then update them,
    # otherwise create a new opportunity. If the opportunity is not valid then a
    # CapsuleCRM::Errors::RecordInvalid exception is raised
    #
    # Examples
    #
    # opportunity = CapsuleCRM::Opportunity.new(name: 'Test, milestone_id: 1)
    # opportunity.save
    #
    # opportunity = CapsuleCRM::Opportunity.find(1)
    # opportunity.name = 'Another test'
    # opportunity.save
    #
    # Returns a CapsuleCRM::opportunity
    def save!
      if valid?
        new_record? ? create_record : update_record
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    # Public: Determine whether this CapsuleCRM::opportunity is a new record or not
    #
    # Returns a Boolean
    def new_record?
      !id
    end

    # Public: Determine whether or not this CapsuleCRM::opportunity has already been
    # persisted to capsulecrm
    #
    # Returns a Boolean
    def persisted?
      !new_record?
    end

    # Public: Update the opportunity in capsule
    #
    # attributes  - The Hash of opportunity attributes (default: {}):
    #               :name                 - The String opportunity name
    #               :description          - The String opportunity description
    #               :currency             - The String currency code
    #               :value                - The Float opportunity (financial) value
    #               :duration_basis       - The String duration basis
    #               :duration             - The Integer duration (for opportunities
    #               with a repeating (not FIXED) duratin basis
    #               :party_id             - The Integer party id
    #               :milestone_id         - The Integer milestone id
    #               :expected_close_date  - The DateTime when the opportunity
    #               is expected to be closed
    #               :actual_close_date    - The DateTime when the opportunity
    #               was actually closed
    #               :probability          - The Float probability that this
    #               opportunity will be won
    # Examples
    #
    # opportunity = CapsuleCRM::Opportunity.find(1)
    # opportunity.update_attributes name: 'A New Name'
    #
    # Returns a CapsuleCRM::opportunity
    def update_attributes(attributes = {})
      self.attributes = attributes
      save
    end

    # Public: Update the opportunity in capsule. If the person is not valid then a
    # CapsuleCRM::Errors::RecordInvalid exception will be raised
    #
    # attributes  - The Hash of opportunity attributes (default: {}):
    #               :name                 - The String opportunity name
    #               :description          - The String opportunity description
    #               :currency             - The String currency code
    #               :value                - The Float opportunity (financial) value
    #               :duration_basis       - The String duration basis
    #               :duration             - The Integer duration (for opportunities
    #               with a repeating (not FIXED) duratin basis
    #               :party_id             - The Integer party id
    #               :milestone_id         - The Integer milestone id
    #               :expected_close_date  - The DateTime when the opportunity
    #               is expected to be closed
    #               :actual_close_date    - The DateTime when the opportunity
    #               was actually closed
    #               :probability          - The Float probability that this
    #               opportunity will be won
    #
    # Examples
    #
    # opportunity = CapsuleCRM::Opportunity.find(1)
    # opportunity.update_attributes! name: 'A New Name'
    # => CapsuleCRM::Opportunity
    #
    # opportunity.update_attributes! name: nil
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::opportunity
    def update_attributes!(attributes = {})
      self.attributes = attributes
      save!
    end
    #
    # Public: Delete the opportunity in capsule
    #
    # Examples
    #
    # opportunity.destroy
    #
    # Return the CapsuleCRM::Opportunity
    def destroy
      self.id = nil if CapsuleCRM::Connection.delete("/api/opportunity/#{id}")
      self
    end

    private

    def create_record
      path = "/api/party/#{party_id}/opportunity"
      path += "?trackId=#{track_id}" if track_id
      self.attributes = CapsuleCRM::Connection.post(path, to_capsule_json)
      self
    end

    def update_record
      CapsuleCRM::Connection.put("/api/opportunity/#{id}", attributes)
      self
    end
  end
end
