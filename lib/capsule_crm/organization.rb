require 'active_support/core_ext'

module CapsuleCRM
  class Organization < CapsuleCRM::Party
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    extend ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Collection
    include CapsuleCRM::Contactable
    include CapsuleCRM::Serializable

    self.serializable_config do |config|
      config.root               = :organisation
      config.additional_methods = [:contacts]
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
      from_capsule_json CapsuleCRM::Connection.get("/api/party/#{id}")
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
        new_record? ? create_record : update_record
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
    #
    # Public: Delete the organization in capsule
    #
    # Examples
    #
    # organization.destroy
    #
    # Return the CapsuleCRM::Organization
    def destroy
      self.id = nil if CapsuleCRM::Connection.delete("/api/party/#{id}")
      self
    end

    private

    def create_record
      self.attributes = CapsuleCRM::Connection.post(
        '/api/organisation', to_capsule_json
      )
    end

    def update_record
      CapsuleCRM::Connection.put("/api/organisation/#{id}", to_capsule_json)
      self
    end
  end
end
