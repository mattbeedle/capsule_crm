module CapsuleCRM
  class Person < CapsuleCRM::Party
    include CapsuleCRM::Contactable
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Persistence::Deletable
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Serializable

    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    serializable_config do |config|
      config.collection_root    = :parties
      config.additional_methods = [:contacts]
    end

    queryable_config do |config|
      config.singular = :party
    end

    persistable_config do |config|
      config.create = lambda { |person| "person" }
      config.destroy = lambda { |person| "party/#{person.id}" }
    end

    attribute :id, Integer
    attribute :title
    attribute :first_name
    attribute :last_name
    attribute :job_title
    attribute :about
    attribute :organisation_name

    belongs_to :organization, foreign_key: :organisation_id

    validates :id, numericality: { allow_blank: true }
    validates :first_name, presence: { if: :first_name_required? }
    validates :last_name, presence: { if: :last_name_required? }

    # Public: Get all people from Capsule. The list can be restricted
    # and/or paginated with various query parameters sent through the options
    # hash.
    #
    # options - The Hash of allowed query parameters for Capsule (default: {}):
    #           :q      - The String search term that will be matched against
    #           name,
    #           :tag    - The String tag to search for
    #           :start  - The Integer first record to be returned in
    #           pagination.
    #           The results start with an index of 1
    #           :limit  - The Integer maximum number of matching records to be
    #           returned
    #
    # Examples
    #
    # CapsuleCRM::Organization.all
    #
    # CapsuleCRM::Organization.all(q: "a search query", start: 10, limit: 20)
    #
    # Returns a ResultsProxy of organisations
    def self.all(options = {})
      CapsuleCRM::Party.all(options).
        delete_if { |item| !item.is_a?(CapsuleCRM::Person) }
    end

    private

    # Private: Determines whether the person first name is required. Either the
    # first or the last name is always required
    #
    # Returns a Boolean
    def first_name_required?
      last_name.blank?
    end

    # Private: Determines whether the person last name is required. Either the
    # first or the last name is always required
    #
    # Return a Boolean
    def last_name_required?
      first_name.blank?
    end
  end
end
