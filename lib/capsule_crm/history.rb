module CapsuleCRM
  class History
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations

    attribute :id, Integer
    attribute :type, String
    attribute :entry_date, DateTime
    attribute :subject, String
    attribute :note, String

    has_many :attachments,  class_name: 'CapsuleCRM::Attachment'
    has_many :participants, class_name: 'CapsuleCRM::Participant'

    belongs_to :creator,      class_name: 'CapsuleCRM::Person'
    belongs_to :party,        class_name: 'CapsuleCRM::Party'
    belongs_to :kase,         class_name: 'CapsuleCRM::Case',
      foreign_key: :case_id
    belongs_to :opportunity,  class_name: 'CapsuleCRM::Opportunity'

    validates :note, presence: true
    validates :party, :kase, :opportunity,
      presence: { if: :belongs_to_required? }

    # Public: Underscore all of the attributes keys and set the attributes of
    # this history item
    #
    # attributes  - The Hash of history attributes (default: {}):
    #               :id               - The Integer ID of this history item
    #               :creator          - The String username of the creator
    #               (CapsuleCRM::User) OR a CapsuleCRM::User object
    #               :type             - The String type (Note, Email or Task)
    #               :note             - The String note
    #               :subject          - The String email subject if this history
    #               item is from an email
    #               :entry_date       - The date when this history item was
    #               created
    #               :attachments      - An Array of CapsuleCRM::Attachment
    #               objects OR an Array of CapsuleCRM::Attachment attributes
    #               hashes
    #               :participants     - An Array of CapsuleCRM::Participant
    #               objects OR an Array of CapsuleCRM::Participant attributes
    #               hashes
    #               :party_id         - The Integer ID of the party that this
    #               history item belongs to
    #               :case_id          - The Integer ID of the case that this
    #               history item belongs to
    #               :opportunity_id   - The Integer ID of the opportunity that
    #               this item belongs to
    #
    # Examples
    #
    # history = CapsuleCRM::History.new
    # history.attributes = { entry_date: Time.now }
    #
    # or
    #
    # history.attributes = { entryDate: Time.now }
    #
    # Returns a CapsuleCRM::History object
    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
      self
    end

    # Public: find a CapsuleCRM::History by ID
    #
    # id  - The Integer CapsuleCRM::History ID
    #
    # Examples
    #
    # CapsuleCRM::History.find(2)
    #
    # Returns a CapsuleCRM::History object
    def self.find(id)
      new CapsuleCRM::Connection.get("/api/history/#{id}")['historyItem']
    end

    # Public: Set the creator of this history item
    #
    # user  - The String username OR a CapsuleCRM::User object
    #
    # Examples
    #
    # history = CapsuleCRM::History.new
    # history.creator = 'a.username'
    #
    # user = CapsuleCRM::User.find_by_username('another.username')
    # history.creator = user
    #
    # Returns the CapsuleCRM::History object
    def creator=(user)
      if user.is_a?(String)
        user = CapsuleCRM::User.find_by_username(user)
      end
      @creator = user
      self
    end

    # Public: create a CapsuleCRM::History item and persist it
    #
    # attributes  - The Hash of attributes (default: {}):
    #               :note       - The String note
    #               :creator    - The CapsuleCRM::User who created this history
    #               item
    #               :entry_date   - The date when this history item was created
    #
    # Examples
    #
    # CapsuleCRM::History.create(note: 'Some history note text')
    #
    # person = CapsuleCRM::User.find_by_username('some.username')
    # CapsuleCRM::History.create(
    #   note: 'another note to add to the history', person: person,
    #   entry_date: Time.now
    # )
    #
    # Returns a CapsuleCRM::History object
    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    # Public: create a CapsuleCRM::History item and persist it. If persistence
    # is not possible then raise an error
    #
    # attributes  - The Hash of attributes (default: {}):
    #               :note       - The String note
    #               :creator    - The CapsuleCRM::User who created this history
    #               item
    #               :entry_date   - The date when this history item was created
    #
    # Examples
    #
    # CapsuleCRM::History.create!(note: 'Some history note text')
    #
    # person = CapsuleCRM::User.find_by_username('some.username')
    # CapsuleCRM::History.create!(
    #   note: 'another note to add to the history', person: person,
    #   entry_date: Time.now
    # )
    #
    # CapsuleCRM::History.create! {}
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::History object
    def self.create!(attributes = {})
      new(attributes).tap(&:save!)
    end

    # Public: update the attributes of a CapsuleCRM::History item and persist
    # the changes
    #
    # attributes  - The Hash of attributes (default: {}):
    #               :note         - The String note
    #               :creator      - The String creator username OR
    #               a CapsuleCRM::Person object
    #               :entry_date   - The DateTime when the history item was
    #               created
    #
    # Examples
    #
    # history = CapsuleCRM::History.find(1)
    # history.update_attributes note: 'some updated note text'
    #
    # Returns a CapsuleCRM::History item or false
    def update_attributes(attributes = {})
      self.attributes = attributes
      save
    end

    # Public: update the attributes of a CapsuleCRM::History item and persist
    # the changes. If persistence is not possible then raise an error
    #
    # attributes  - The Hash of attributes (default: {}):
    #               :note         - The String note
    #               :creator      - The String creator username OR
    #               a CapsuleCRM::Person object
    #               :entry_date   - The DateTime when the history item was
    #               created
    #
    # Examples
    #
    # history = CapsuleCRM::History.find(1)
    # history.update_attributes note: 'some updated note text'
    #
    # history.update_attributes note: nil
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::History item or a CapsuleCRM::Errors::RecordInvalid
    def update_attributes!(attributes = {})
      self.attributes = attributes
      save!
    end

    # Public: Save this history item. If it is already existing in capsule crm
    # then update it, otherwise create a new one
    #
    # Examples
    #
    # CapsuleCRM::History.new(note: 'some note text').save
    #
    # Returns a CapsuleCRM::History object of false
    def save
      if valid?
        new_record? ? create_record : update_record
      else
        false
      end
    end

    # Public: Save this history item. If it is already existing in capsule crm
    # then update it, otherwise create a new one. If persistence is not possible
    # then raise an error
    #
    # Examples
    #
    # CapsuleCRM::History.new(note: 'the note text').save!
    #
    # CapsuleCRM::History.new.save!
    # => CapsuleCRM::Errors::RecordInvalid
    #
    # Returns a CapsuleCRM::History object
    def save!
      if valid?
        new_record? ? create_record : update_record
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    # Public: Delete this history item from capsule crm.
    #
    # Examples
    #
    # CapsuleCRM::History.find(1).destroy
    #
    # Returns the CapsuleCRM::History object
    def destroy
      self.id = nil if CapsuleCRM::Connection.delete("/api/history/#{id}")
      self
    end

    # Public: Is this history item a new record?
    #
    # Examples
    #
    # CapsuleCRM::History.new.new_record?
    # => true
    #
    # CapsuleCRM::History.find(1).new_record?
    # => false
    def new_record?
      !id
    end

    # Public: Is this history item persisted?
    #
    # Examples
    #
    # CapsuleCRM::History.new.persisted?
    # => fale
    #
    # CapsuleCRM::History.find(1).persisted?
    # => true
    def persisted?
      !new_record?
    end

    # Public: Generate the attributes hash to send to capsule
    #
    # Examples
    #
    # CapsuleCRM::History.find(1).to_capsule_json
    #
    # Returns a Hash of attributes
    def to_capsule_json
      {
        historyItem: CapsuleCRM::HashHelper.camelize_keys(
          {
            note: note, entry_date: entry_date, creator: creator.try(:username)
          }.delete_if { |key, value| value.blank? }
        )
      }
    end

    private

    def belongs_to_required?
      party.blank? && kase.blank? && opportunity.blank?
    end

    def create_record
      self.attributes = CapsuleCRM::Connection.post(
        "/api/#{belongs_to_api_name}/#{belongs_to_id}/history", to_capsule_json
      )
      self
    end

    def belongs_to_api_name
      {
        person: 'party', organization: 'party', case: 'kase',
        opportunity: 'opportunity'
      }.stringify_keys[belongs_to_name]
    end

    def belongs_to_name
      (party || kase || opportunity).class.to_s.demodulize.downcase
    end

    def belongs_to_id
      (party || kase || opportunity).id
    end

    def update_record
      CapsuleCRM::Connection.put("/api/history/#{id}", to_capsule_json)
    end
  end
end