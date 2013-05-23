module CapsuleCRM
  class Task
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations::BelongsTo

    attribute :due_date, DateTime
    attribute :category, String
    attribute :description, String
    attribute :detail, String

    belongs_to :party, class_name: 'CapsuleCRM::Party'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'
    belongs_to :case, class_name: 'CapsuleCRM::Case'
    belongs_to :owner, class_name: 'CapsuleCRM::User'

    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end

    def owner=(user)
      user = CapsuleCRM::User.find_by_username(user) if user.is_a?(String)
      @owner = user
      self
    end

    def self.all
    end

    def self.find(id)
      new CapsuleCRM::Connection.get("/api/tasks/#{id}")['task']
    end

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

    def complete
    end

    def re_open
    end

    def self.categories
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