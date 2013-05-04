module CapsuleCRM
  class Opportunity
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :id, Integer
    attribute :name
    attribute :description
    attribute :currency
    attribute :value, Float
    attribute :duration_basis
    attribute :duration, Integer
    attribute :party_id, Integer
    attribute :milestone_id, Integer
    attribute :expected_close_date, DateTime
    attribute :actual_close_date, DateTime
    attribute :probability, Float

    attr_accessor :milestone, :owner

    validates :name, presence: true
    validates :milestone_id, presence: { unless: :milestone }
    validates :milestone, presence: { unless: :milestone_id }

    # Public: Set the attributes of a person
    #
    # attributes  - The Hash of attributes (default: {}):
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
    # CapsuleCRM::Opportunity.new
    #
    # Returns a CapsuleCRM::Opportunity
    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
      self
    end

    # Public: Get all opportunities from Capsule. The list can be restricted
    # and/or paginated with various query parameters sent through the options
    # hash.
    #
    # options - The Hash of allowed query parameters for Capsule (default: {}):
    #           :milestone      - The String milestone name
    #           :lastmodified   - The Date when the opportunity was last modified
    #           :tag            - The String tag to search for
    #           :start          - The Integer first record to be returned in pagination.
    #           The results start with an index of 1
    #           :limit          - The Integer maximum number of matching records to be
    #           returned
    #
    # Examples
    #
    # CapsuleCRM::Opportunity.all
    #
    # CapsuleCRM::Opportunity.all(start: 10, limit: 20)
    #
    # Returns a ResultsProxy of organisations
    def self.all(options = {})
      init_collection(
        CapsuleCRM::Connection.
        get('/api/opportunity', options)['opportunities']['opportunity']
      )
    end

    def self.find(id)
      new CapsuleCRM::Connection.get("/api/opportunity/#{id}")['opportunity']
    end

    private

    def self.init_collection(collection)
      CapsuleCRM::ResultsProxy.new(collection.map { |item| new item })
    end
  end
end