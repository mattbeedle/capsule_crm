require 'active_support/core_ext'

module CapsuleCRM
  class Organization < CapsuleCRM::Party
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    extend ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Contactable
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Persistence::Deletable
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Querying::FindOne
    include CapsuleCRM::Serializable

    queryable_config do |config|
      config.singular = :party
    end

    serializable_config do |config|
      config.root               = :organisation
      config.additional_methods = [:contacts]
    end

    persistable_config do |config|
      config.create = lambda { |org| "organisation" }
      config.destroy = lambda { |org| "party/#{org.id}" }
    end

    attribute :id,    Integer
    attribute :name,  String
    attribute :about, String

    validates :name, presence: true

    has_many :people, class_name: 'CapsuleCRM::Person', source: :organization
    has_many :custom_fields, class_name: 'CapsuleCRM::CustomField',
      source: :party

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
        delete_if { |item| !item.is_a?(CapsuleCRM::Organization) }
    end
  end
end
