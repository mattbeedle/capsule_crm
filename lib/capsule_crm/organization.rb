require 'active_support/core_ext'

module CapsuleCRM
  class Organization
    include ::Virtus

    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    extend ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attribute :name
    attribute :about

    validates :name, presence: true

    # Public: Set the attributes of an organization
    #
    # attributes  - The Hash of attributes (default: {}):
    #               :name   - The String organization name
    #               :about  - The String information about the organization
    #
    # Examples
    #
    # CapsuleCRM::Organization.new
    #
    # Returns a CapsuleCRM::Organization
    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
      self
    end

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
      init_collection(
        CapsuleCRM::Connection.
        get('/api/party', options)['parties']['organisation']
      )
    end

    # Public: Get an organization by ID
    #
    # id  - The Integer organization ID
    #
    # Examples
    #
    # CapsuleCRM::Organization.find(1)
    #
    # Returns a CapsuleCRM::Organization
    def self.find(id)
      new CapsuleCRM::Connection.get("/api/party/#{id}")['organisation']
    end

    # Public: Create a new organization in capsulecrm
    #
    # attributes  - The Hash of organization attributes (default: {}):
    #               :name   - The String organization name
    #               :about  - The String information about the organization
    #
    # Examples
    #
    # CapsuleCRM::Organization.create(name: 'Google Inc')
    #
    # Returns a CapsuleCRM::Organization
    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    # Public: Create a new organization in capsulecrm and raise a
    # CapsuleCRM::Errors::InvalidRecord error if not possible
    #
    # attributes  - The Hash of organization attributes (default: {}):
    #               :name   - The String organization name
    #               :about  - The String information about the organization
    #
    # Examples
    #
    # CapsuleCRM::Organization.create!(name: 'Google Inc')
    #
    # Returns a CapsuleCRM
    def self.create!(attributes = {})
      new(attributes).tap(&:save!)
    end

    # Public: If the organization already exists in capsule then update them,
    # otherwise create a new organization
    #
    # Examples
    #
    # organization = CapsuleCRM::Organization.new(name: 'Google Inc')
    # organization.save
    #
    # organization = CapsuleCRM::Organization.find(1)
    # organization.name = 'Apple'
    # organization.save
    #
    # Returns a CapsuleCRM::Organization
    def save
      if valid?
        new_record? ? create_record : update_record
      else
        false
      end
    end

    # Public: If the organization already exists in capsule then update them,
    # otherwise create a new organization. If the organization is not valid
    # then a CapsuleCRM::Errors::RecordInvalid exception is raised
    #
    # Examples
    #
    # organization = CapsuleCRM::Organization.new(name: 'Google Inc')
    # organization.save!
    #
    # organization = CapsuleCRM::Organization.find(1)
    # organization.name = 'Apple'
    # organization.save!
    #
    # organization = CapsuleCRM::Organization.new
    # organization.save!
    # => CapsuleCRM::Errors::InvalidRecord
    #
    # Returns a CapsuleCRM::Organization
    def save!
      if valid?
        new_record ? create_record : update_record
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    # Public: Update the organization in capsule
    #
    # attributes  - The Hash of organization attributes (default: {}):
    #               :name   - The String organization name
    #               :about  - The String information about the organization
    #
    # Examples
    #
    # organization = CapsuleCRM::Organization.find(1)
    # organization.update_attributes name: 'Google Inc'
    # => true
    #
    # organization.update_attributes {}
    # => false
    #
    # Returns a CapsuleCRM::Organization
    def update_attributes(attributes = {})
      self.attributes = attributes
      save
    end

    # Public: Update the organization in capsule. If the organization is not
    # valid then a CapsuleCRM::Errors::RecordInvalid exception will be raised
    #
    # attributes  - The Hash of organization attributes (default: {}):
    #               :name   - The String organization name
    #               :about  - The String information about the organization
    #
    # Examples
    #
    # organization = CapsuleCRM::Organization.find(1)
    # organization.update_attributes! name: 'Microsoft'
    # => true
    #
    # organization = CapsuleCRM::Organization.find(1)
    # organization.update_attributes!
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::Organization
    def update_attributes!(attributes = {})
      self.attributes = attributes
      save!
    end

    # Public: Determine whether this CapsuleCRM::Organization is a new record
    # or not
    #
    # Returns a Boolean
    def new_record?
      !id
    end

    # Public: Determine whether or not this CapsuleCRM::Organization has
    # already been persisted to capsulecrm
    #
    # Returns a Boolean
    def persisted?
      !new_record?
    end

    # Public: Build a hash of attributes and merge in the attributes for the
    # contact information
    #
    # Examples
    #
    # organization.to_capsule_json
    #
    # Returns a Hash
    def to_capsule_json
      {
        organisation: attributes.merge(contacts: contacts.to_capsule_json).
        stringify_keys
      }.stringify_keys
    end

    private

    def create_record
      self.attributes = CapsuleCRM::Connection.post(
        '/api/organisation', to_capsule_json
      )
    end

    def update_record
      CapsuleCRM::Connection.put("/api/organisation/#{id}", attributes)
    end

    # Private: Build a ResultsProxy from a Array of CapsuleCRM::Organization
    # attributes
    #
    # collection  - The Array of CapsuleCRM::Organization attributes hashes
    #
    # Returns a CapsuleCRM::ResultsProxy
    def self.init_collection(collection)
      CapsuleCRM::ResultsProxy.new(collection.map { |item| new item })
    end
  end
end
