class CapsuleCRM::Person
  include Virtus

  include CapsuleCRM::Associations::HasMany

  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attribute :title
  attribute :first_name
  attribute :last_name
  attribute :about
  attribute :organization_name
  attribute :organization_id

  validates :first_name, presence: { if: :first_name_required? }
  validates :last_name, presence: { if: :last_name_required? }

  has_many :addresses
  has_many :emails
  has_many :phones
  has_many :websites

  # Public: Instantiate a new CapsuleCRM::Person
  #
  # attributes  - The Hash of attributes (default: {}):
  #               :first_name         - The String person first name
  #               :last_name          - The String person last name
  #               :about              - The String information about the person
  #               :organization_name  - The String name of the organization.
  #
  # Examples
  #
  # CapsuleCRM::Person.new
  #
  # Returns a CapsuleCRM::Person
  def initialize(attributes = {})
    CapsuleCRM::HashHelper.underscore_keys!(attributes)
    super(attributes)
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
  # Returns a ResultsProxy of organizations
  def self.all(options = {})
    init_collection CapsuleCRM::Connection.get('/api/party', options)['parties']['person']
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
  #               :about              - The String information about the person
  #               :organization_name  - The String organization name. If now
  #               :organization_id is supplied, then a new one will be created
  #               with this name
  #               :organization_id    - The Integer ID of the organization this
  #               person belongs to
  #
  # Examples
  #
  # CapsuleCRM::Person.create(first_name: 'Matt', last_name: 'Beedle')
  #
  # Returns a CapsuleCRM::Person
  def create(attributes = {})
    connection.post('/api/person', attributes)
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
    if new_record?
      create(attributes)
    else
      update_attributes attributes
    end
  end

  # Public: Update the person in capsule
  #
  # attributes  - The Hash of person attributes (default: {}):
  #               :first_name         - The String first name
  #               :last_name          - The String last name
  #               :about              - The String information about the person
  #               :organization_name  - The String organization name
  #               :organization_id    - The String organization id
  #
  # Examples
  #
  # person = CapsuleCRM::Person.find(1)
  # person.update_attributes first_name: 'Matt', last_name: 'Beedle'
  #
  # Returns a CapsuleCRM::Person
  def update_attributes(attributes = {})
    connection.post("/api/person/#{id}", attributes)
  end

  private

  def self.init_collection(collection)
    CapsuleCRM::ResultsProxy.new(collection.map { |item| new item })
  end

  def first_name_required?
    last_name.blank?
  end

  def last_name_required?
    first_name.blank?
  end
end
