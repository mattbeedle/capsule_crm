module CapsuleCRM
  class History
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Inspector
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Persistence::Deletable
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

    queryable_config do |config|
      config.plural = :history
    end

    attribute :id, Integer
    attribute :type, String
    attribute :entry_date, DateTime
    attribute :subject, String
    attribute :note, String

    has_many :attachments
    has_many :participants

    belongs_to :creator,      serializable_key: :creator,
      class_name: 'CapsuleCRM::Person'
    belongs_to :party,        serialize: false
    belongs_to :case,         serialize: false
    belongs_to :opportunity,  serialize: false

    validates :id, numericality: { allow_blank: true }
    validates :note, presence: true
    validates :party, :case, :opportunity,
      presence: { if: :belongs_to_required? }

    class << self
      alias :_for_organization :_for_party
      alias :_for_person :_for_party
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

    def belongs_to_api_name
      {
        person: 'party', organization: 'party', case: 'case',
        opportunity: 'opportunity'
      }.stringify_keys[belongs_to_name]
    end

    def belongs_to_id
      (party || self.case || opportunity).try(:id)
    end

    private

    def belongs_to_required?
      party.blank? && self.case.blank? && opportunity.blank?
    end

    def belongs_to_name
      (party || self.case || opportunity).class.to_s.demodulize.downcase
    end
  end
end
