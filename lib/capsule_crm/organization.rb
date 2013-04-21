require 'active_support/core_ext'

class CapsuleCRM::Organization
  include ::Virtus

  include CapsuleCRM::Associations

  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  extend ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attribute :name
  attribute :about

  # has_many :people

  validates :name, presence: true

  # Public: Get all organizations from Capsule. The list can be restricted
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
  # Organization.all
  #
  # Organization.all(q: "a search query", start: 10, limit: 20)
  #
  # Returns a ResultsProxy of organizations
  def self.all(options = {})
    options.delete_if { |key, value| !allowed_filtering_options.include?(key) }
    delete_invalid_options(options)
    CapsuleCRM::ResultsProxy.new(
      CapsuleCRM::Connection.get('/api/party', options).map do |result|
        new(result)
      end
    )
  end

  def self.find(id)
    new CapsuleCRM::Connection.get("/api/party/#{id}")
  end

  def save
    if new_record?
      create(attributes)
    else
      update(attributes)
    end
  end

  def create(attributes = {})
    CapsuleCRM::Connection.post('/api/organization', attributes)
  end

  def update_attributes(attributes = {})
    CapsuleCRM::Connection.put("/api/organization/#{id}", attributes)
  end

  private

  def delete_invalid_all_options(options)
    options.stringify_keys!
    options.delete_if do |key, value|
      !allowed_filtering_options.include?(key)
    end
  end

  def allowed_filtering_options
    %w(q email last_modified tag start limit)
  end
end
