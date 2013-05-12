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

    has_many :attachments, class_name: 'CapsuleCRM::Attachment'
    has_many :participants, class_name: 'CapsuleCRM::Participant'

    belongs_to :party, class_name: 'CapsuleCRM::Party'
    belongs_to :case, class_name: 'CapsuleCRM::Case'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'

    def self.create(attributes = {})
    end

    def self.create!(attributes = {})
    end

    def update_attributes(attributes = {})
    end

    def update_attributes!(attributes = {})
    end

    def save
    end

    def save!
    end

    def destroy
    end

    def new_record?
    end

    def persisted?
    end

    private

    def create_record
    end

    def update_record
    end
  end
end