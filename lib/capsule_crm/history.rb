module CapsuleCRM
  class History
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations

    attribute :id, Integer
    attribute :type, String
    attribute :entry_date, Date
    attribute :creator, String
    attribute :creator_name, String
    attribute :subject, String
    attribute :note, String

    has_many :attachments,  class_name: 'CapsuleCRM::Attachment'
    has_many :participants, class_name: 'CapsuleCRM::Participant'

    belongs_to :party,       class_name: 'CapsuleCRM::Party'
    belongs_to :kase,        class_name: 'CapsuleCRM::Case'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'

    validates :note, presence: true
    validates :party, :kase, :opportunity,
      presence: { if: :belongs_to_required? }

    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    def self.create!(attributes = {})
      new(attributes).tap(&:save!)
    end

    def update_attributes(attributes = {})
      self.attributes = attributes
      save
    end

    def update_attributes!(attributes = {})
      self.attributes = attributes
      save!
    end

    def save
      if valid?
        new_record? ? create_record : update_record
      else
        false
      end
    end

    def save!
      if valid?
        new_record? ? create_record : update_record
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    def destroy
      self.id = nil if CapsuleCRM::Connection.delete("/api/history/#{id}")
      self
    end

    def new_record?
      !id
    end

    def persisted?
      !new_record?
    end

    def to_capsule_json
      {}
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