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
    belongs_to :case,        class_name: 'CapsuleCRM::Case'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'

    validates :note, presence: true

    def self.create(attributes = {})
    end

    def self.create!(attributes = {})
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
    end

    def new_record?
      !id
    end

    def persisted?
      !new_record?
    end

    def to_capsule_json
    end

    private

    def create_record
    end

    def update_record
      CapsuleCRM::Connection.put("/api/history/#{id}", to_capsule_json)
    end
  end
end