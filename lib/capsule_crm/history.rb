module CapsuleCRM
  class History
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Querying::Configuration
    include CapsuleCRM::Querying::FindOne
    include CapsuleCRM::Serializable

    persistable_config do |config|
      config.create = lambda do |history|
        "#{history.belongs_to_api_name}/#{history.belongs_to_id}/history"
      end
    end

    serializable_config do |config|
      config.root            = :historyItem
      config.collection_root = :history
    end

    attribute :id, Integer
    attribute :type, String
    attribute :entry_date, DateTime
    attribute :subject, String
    attribute :note, String

    has_many :attachments,  class_name: 'CapsuleCRM::Attachment'
    has_many :participants, class_name: 'CapsuleCRM::Participant'

    belongs_to :creator,      class_name: 'CapsuleCRM::Person',
      serializable_key: :creator
    belongs_to :party,        class_name: 'CapsuleCRM::Party', serialize: false
    belongs_to :kase,         class_name: 'CapsuleCRM::Case',
      foreign_key: :case_id, serialize: false
    belongs_to :opportunity,  class_name: 'CapsuleCRM::Opportunity',
      serialize: false

    validates :id, numericality: { allow_blank: true }
    validates :note, presence: true
    validates :party, :kase, :opportunity,
      presence: { if: :belongs_to_required? }

    def self._for_party(party_id)
      CapsuleCRM::Normalizer.new(self).normalize_collection(
        CapsuleCRM::Connection.get("/api/party/#{party_id}/history")
      )
    end

    class << self
      alias :_for_organization :_for_party
      alias :_for_person :_for_party
    end

    def self._for_case(case_id)
      CapsuleCRM::Normalizer.new(self).normalize_collection(
        CapsuleCRM::Connection.get("/api/kase/#{case_id}/history")
      )
    end

    def self._for_opportunity(opportunity_id)
      CapsuleCRM::Normalizer.new(self).normalize_collection(
        CapsuleCRM::Connection.
          get("/api/opportunity/#{opportunity_id}/history")
      )
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

    def belongs_to_api_name
      {
        person: 'party', organization: 'party', case: 'kase',
        opportunity: 'opportunity'
      }.stringify_keys[belongs_to_name]
    end

    def belongs_to_id
      (party || kase || opportunity).id
    end

    private

    def belongs_to_required?
      party.blank? && kase.blank? && opportunity.blank?
    end

    def belongs_to_name
      (party || kase || opportunity).class.to_s.demodulize.downcase
    end
  end
end
