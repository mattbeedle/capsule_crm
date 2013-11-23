module CapsuleCRM
  class Case
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Collection
    include CapsuleCRM::Associations::HasMany
    include CapsuleCRM::Associations::BelongsTo
    include CapsuleCRM::Taggable

    attribute :id, Integer
    attribute :name, String
    attribute :description, String
    attribute :status, String
    attribute :close_date, Date
    attribute :owner, String

    validates :name, presence: true
    validates :party, presence: true

    belongs_to :party, class_name: 'CapsuleCRM::Party'
    belongs_to :track, class_name: 'CapsuleCRM::Track'

    has_many :tasks, class_name: 'CapsuleCRM::Task', source: :case

    # Public: Search and retrieve all cases in CapsuleCRM
    #
    # options   - the Hash of query options (default: {}):
    #             :tag            - the String tag to search for
    #             :lastmodified   - the Date after which the case was last
    #             modified by
    #             :start          - the Integer index of the first record to
    #             return.
    #             :limit          - the Integer number of records to return
    #
    # Examples
    #
    # CapsuleCRM::Case.all(tag: 'Some Tag')
    #
    # Returns a CapsuleCRM::ResultsProxy of CapsuleCRM::Case objects
    def self.all(options = {})
      init_collection(
        CapsuleCRM::Connection.get('/api/kase', options)['kases']['kase']
      )
    end

    # Public: Search for a single case by ID
    #
    # id - the Integer ID of the record to search for
    #
    # Examples
    #
    # CapsuleCRM::Case.find(1)
    #
    # Returns a CapsuleCRM::Case object
    def self.find(id)
      new CapsuleCRM::Connection.get("/api/kase/#{id}")['kase']
    end

    # Public: Create a CapsuleCRM::Case
    #
    # attributes  - the Hash of attributes (default: {}):
    #               :name         - the String name of the case (required)
    #               :description  - the String description
    #               :status       - the String status (OPEN or CLOSED), default
    #               is OPEN
    #               :owner        - the String username of the owner
    #               :close_date   - the Date when the case was/will be closed.
    #               Ignored if the status is set to CLOSED
    #
    # Examples
    #
    # CapsuleCRM::Case.create name: "Matt's test case"
    #
    # Returns a CapsuleCRM::Case
    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    # Public: Create a CapsuleCRM::Case or raise a error
    #
    # attributes  - the Hash of attributes (default: {}):
    #               :name         - the String name of the case (required)
    #               :description  - the String description
    #               :status       - the String status (OPEN or CLOSED), default
    #               is OPEN
    #               :owner        - the String username of the owner
    #               :close_date   - the Date when the case was/will be closed.
    #               Ignored if the status is set to CLOSED
    #
    # Examples
    #
    # CapsuleCRM::Case.create! name: "Matt's test case"
    # => CapsuleCRM::Case object
    #
    # CapsuleCRM::Case.create! name: nil
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::Case
    def self.create!(attributes = {})
      new(attributes).tap(&:save!)
    end

    # Public: Updates an existing CapsuleCRM::Case with the supplied attributes
    #
    # attributes  - the Hash of attributes (default: {}):
    #               :name         - the String name of the case (required)
    #               :description  - the String description
    #               :status       - the String status (OPEN or CLOSED), default
    #               is OPEN
    #               :owner        - the String username of the owner
    #               :close_date   - the Date when the case was/will be closed.
    #               Ignored if the status is set to CLOSED
    #
    # Examples
    #
    # kase = CapsuleCRM::Case.find(1)
    # kase.update_attributes name: 'A new name'
    #
    # Returns a CapsuleCRM::Case
    def update_attributes(attributes = {})
      self.attributes = attributes
      save
    end

    # Public: Updates an existing CapsuleCRM::Case with the supplied attributes
    # or raises an error
    #
    # attributes  - the Hash of attributes (default: {}):
    #               :name         - the String name of the case (required)
    #               :description  - the String description
    #               :status       - the String status (OPEN or CLOSED), default
    #               is OPEN
    #               :owner        - the String username of the owner
    #               :close_date   - the Date when the case was/will be closed.
    #               Ignored if the status is set to CLOSED
    #
    # Examples
    #
    # kase = CapsuleCRM::Case.find(1)
    # kase.update_attributes! name: 'A new name'
    # => CapsuleCRM::Case object
    #
    # kase.update_attributes! name: nil
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::Case
    def update_attributes!(attributes = {})
      self.attributes = attributes
      save!
    end

    # Public: Saves this CapsuleCRM::Case
    #
    # Examples:
    #
    # kase = CapsuleCRM::Case.new(
    #   name: 'Case Name', party: person_or_organization
    # )
    # kase.save
    # => CapsuleCRM::Case object
    #
    # Returns the CapsuleCRM::Case or false
    def save
      if valid?
        new_record? ? create_record : update_record
      else
        false
      end
    end

    # Public: Saves this CapsuleCRM::Case or raises an error
    #
    # Examples
    #
    # kase = CapsuleCRM::Case.find(1)
    # kase.name = 'Changed name'
    # kase.save!
    # => CapsuleCRM::Case object
    #
    # kase.name = nil
    # kase.save!
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::Case
    def save!
      if valid?
        new_record? ? create_record : update_record
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    # Public: Deletes this CapsuleCRM::Case from CapsuleCRM
    #
    # Examples
    #
    # CapsuleCRM::Case.find(1).destroy
    #
    # Returns the CapsuleCRM::Case object
    def destroy
      self.id = nil if CapsuleCRM::Connection.delete("/api/kase/#{id}")
      self
    end

    # Public: Is this case a new record?
    #
    # Examples
    #
    # CapsuleCRM::Case.find(1).new_record?
    # => false
    #
    # CapsuleCRM::Case.new.new_record?
    # => true
    #
    # Returns a Boolean
    def new_record?
      !id
    end

    # Public: Is this case persisted to CapsuleCRM?
    #
    # Examples
    #
    # CapsuleCRM::Case.find(1).persisted?
    # => true
    #
    # CapsuleCRM::Case.new.persisted?
    # => false
    #
    # Returns a Boolean
    def persisted?
      !new_record?
    end

    def to_capsule_json
      {
        kase: CapsuleCRM::HashHelper.camelize_keys(
          attributes.dup.delete_if do |key, value|
            value.blank? || key == 'track_id'
          end
        )
      }
    end

    def self._for_track(track)
      raise NotImplementedError.new("There is no way to find cases by trackId in the Capsule API right now")
    end

    private

    def create_record
      path = "/api/party/#{party_id}/kase"
      path += "?trackId=#{track_id}" if track_id
      self.attributes = CapsuleCRM::Connection.post(
        path, to_capsule_json
      )
      self
    end

    def update_record
      CapsuleCRM::Connection.put("/api/kase/#{id}", to_capsule_json)
    end
  end
end
