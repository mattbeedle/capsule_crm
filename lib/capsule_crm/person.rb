class CapsuleCRM::Person
  include Virtus

  include CapsuleCRM::Contactable

  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attribute :id
  attribute :title
  attribute :first_name
  attribute :last_name
  attribute :job_title
  attribute :about
  attribute :organisation_name
  attribute :organisation_id

  validates :first_name, presence: { if: :first_name_required? }
  validates :last_name, presence: { if: :last_name_required? }

  # Public: Set the attributes of a person
  #
  # attributes  - The Hash of attributes (default: {}):
  #               :first_name         - The String person first name
  #               :last_name          - The String person last name
  #               :job_title          - The String job title
  #               :about              - The String information about the person
  #               :organisation_name  - The String name of the organisation. If
  #               this organisation does not exist in capsule then a new one
  #               will be created on save
  #               :organisation_id    - The Integer ID of the organisation in
  #               capsulecrm.
  #
  # Examples
  #
  # CapsuleCRM::Person.new
  #
  # Returns a CapsuleCRM::Person
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
  #           :q      - The String search term that will be matched against name,
  #           telephone number and exact match on searchable custom fields
  #           :email  - The String email address to search for
  #           :tag    - The String tag to search for
  #           :start  - The Integer first record to be returned in pagination.
  #           The results start with an index of 1
  #           :limit  - The Integer maximum number of matching records to be
  #           returned
  #
  # Examples
  #
  # CapsuleCRM::Person.all
  #
  # CapsuleCRM::Person.all(q: "a search query", start: 10, limit: 20)
  #
  # Returns a ResultsProxy of organisations
  def self.all(options = {})
    init_collection(
      CapsuleCRM::Connection.get('/api/party', options)['parties']['person']
    )
  end

  # Public: Get a person by ID
  #
  # id  - The Integer person ID
  #
  # Examples
  #
  # CapsuleCRM::Person.find(1)
  #
  # Returns a CapsuleCRM::Person
  def self.find(id)
    new CapsuleCRM::Connection.get("/api/party/#{id}")['person']
  end

  # Public: Create a new person in capsulecrm
  #
  # attributes  - The Hash of person attributes (default: {}):
  #               :first_name         - The String first name
  #               :last_name          - The String last name
  #               :job_title          - The String job title
  #               :about              - The String information about the person
  #               :organisation_name  - The String organisation name. If now
  #               :organisation_id is supplied, then a new one will be created
  #               with this name
  #               :organisation_id    - The Integer ID of the organisation this
  #               person belongs to
  #
  # Examples
  #
  # CapsuleCRM::Person.create(first_name: 'Matt', last_name: 'Beedle')
  #
  # Returns a CapsuleCRM::Person
  def self.create(attributes = {})
    new(attributes).tap(&:save)
  end

  # Public: Create a new person in capsulecrm and raise a
  # CapsuleCRM::Errors::InvalidRecord error if not possible
  #
  # attributes  - The Hash of person attributes (default: {}):
  #               :first_name         - The String first name
  #               :last_name          - The String last name
  #               :job_title          - The String job title
  #               :about              - The String information about the person
  #               :organisation_name  - The String organisation name. If now
  #               :organisation_id is supplied, then a new one will be created
  #               with this name
  #               :organisation_id    - The Integer ID of the organisation this
  #               person belongs to
  #
  # Examples
  #
  # CapsuleCRM::Person.create!(first_name: 'Matt', last_name: 'Beedle')
  #
  # Returns a CapsuleCRM
  def self.create!(attributes = {})
    new(attributes).tap(&:save!)
  end

  # Public: If the person already exists in capsule then update them,
  # otherwise create a new person
  #
  # Examples
  #
  # person = CapsuleCRM::Person.new(first_name: 'Matt')
  # person.save
  #
  # person = CapsuleCRM::Person.find(1)
  # person.first_name = 'Matt'
  # person.save
  #
  # Returns a CapsuleCRM::Person
  def save
    if valid?
      new_record? ? create_record : update_record
    else
      false
    end
  end

  # Public: If the person already exists in capsule then update them,
  # otherwise create a new person. If the person is not valid then a
  # CapsuleCRM::Errors::RecordInvalid exception is raised
  #
  # Examples
  #
  # person = CapsuleCRM::Person.new(first_name: 'Matt')
  # person.save
  #
  # person = CapsuleCRM::Person.find(1)
  # person.first_name = 'Matt'
  # person.save
  #
  # Returns a CapsuleCRM::Person
  def save!
    if valid?
      new_record ? create_record : update_record
    else
      raise CapsuleCRM::Errors::RecordInvalid.new(self)
    end
  end

  # Public: Update the person in capsule
  #
  # attributes  - The Hash of person attributes (default: {}):
  #               :first_name         - The String first name
  #               :last_name          - The String last name
  #               :job_title          - The String job title
  #               :about              - The String information about the person
  #               :organisation_name  - The String organisation name
  #               :organisation_id    - The String organisation id
  #
  # Examples
  #
  # person = CapsuleCRM::Person.find(1)
  # person.update_attributes first_name: 'Matt', last_name: 'Beedle'
  #
  # Returns a CapsuleCRM::Person
  def update_attributes(attributes = {})
    self.attributes = attributes
    save
  end

  # Public: Update the person in capsule. If the person is not valid then a
  # CapsuleCRM::Errors::RecordInvalid exception will be raised
  #
  # attributes  - The Hash of person attributes (default: {}):
  #               :first_name         - The String first name
  #               :last_name          - The String last name
  #               :job_title          - The String job title
  #               :about              - The String information about the person
  #               :organisation_name  - The String organisation name
  #               :organisation_id    - The String organisation id
  #
  # Examples
  #
  # person = CapsuleCRM::Person.find(1)
  # person.update_attributes first_name: 'Matt', last_name: 'Beedle'
  #
  # Returns a CapsuleCRM::Person
  def update_attributes!(attributes = {})
    self.attributes = attributes
    save!
  end

  # Public: Determine whether this CapsuleCRM::Person is a new record or not
  #
  # Returns a Boolean
  def new_record?
    !id
  end

  # Public: Determine whether or not this CapsuleCRM::Person has already been
  # persisted to capsulecrm
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
  # person.to_capsule_json
  #
  # Returns a Hash
  def to_capsule_json
    attributes.merge(contacts: contacts.to_capsule_json)
  end

  private

  def create_record
    self.attributes = CapsuleCRM::Connection.post(
      '/api/person', to_capsule_json
    )
  end

  def update_record
    CapsuleCRM::Connection.put("/api/person/#{id}", attributes)
  end

  # Private: Build a ResultsProxy from a Array of CapsuleCRM::Person attributes
  #
  # collection  - The Array of CapsuleCRM::Person attributes hashes
  #
  # Returns a CapsuleCRM::ResultsProxy
  def self.init_collection(collection)
    CapsuleCRM::ResultsProxy.new(collection.map { |item| new item })
  end

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
