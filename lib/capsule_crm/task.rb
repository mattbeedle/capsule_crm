module CapsuleCRM
  class Task
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Persistence::Persistable
    include CapsuleCRM::Persistence::Deletable
    include CapsuleCRM::Querying::Findable
    include CapsuleCRM::Serializable

    persistable_config do |config|
      config.create = lambda { |task| task.create_url }
    end

    attribute :id, Integer
    attribute :due_date, Date
    attribute :due_date_time, DateTime
    attribute :category, String
    attribute :description, String
    attribute :detail, String

    belongs_to :party, class_name: 'CapsuleCRM::Party'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'
    belongs_to :case, class_name: 'CapsuleCRM::Case'
    belongs_to :owner, class_name: 'CapsuleCRM::User', serializable_key: :owner

    validates :id, numericality: { allow_blank: true }
    validates :description, presence: true
    validates :due_date, presence: { unless: :due_date_time }
    validates :due_date_time, presence: { unless: :due_date }

    def self._for_party(party_id)
      CapsuleCRM::ResultsProxy.new(
        CapsuleCRM::Task.all.select { |task| task.party_id == party_id }
      )
    end
    class << self
      alias :_for_person :_for_party
      alias :_for_organization :_for_party
    end

    def self._for_opportunity(opportunity_id)
      CapsuleCRM::ResultsProxy.new(
        CapsuleCRM::Task.all.select do |task|
          task.opportunity_id == opportunity_id
        end
      )
    end

    def self._for_case(case_id)
      CapsuleCRM::ResultsProxy.new(
        CapsuleCRM::Task.all.select { |task| task.case_id == case_id }
      )
    end

    def owner=(user)
      user = CapsuleCRM::User.find_by_username(user) if user.is_a?(String)
      @owner = user
      self
    end

    def complete
      CapsuleCRM::Connection.post("/api/task/#{id}/complete")
      self
    end

    def reopen
      CapsuleCRM::Connection.post("/api/task/#{id}/reopen")
      self
    end

    # TODO Change this to an embedded association, like custom fields
    def self.categories
      CapsuleCRM::Connection.
        get('/api/task/categories')['taskCategories']['taskCategory']
    end

    def create_url
      if party_id
        "party/#{party_id}/task"
      elsif opportunity_id
        "opportunity/#{opportunity_id}/task"
      elsif case_id
        "kase/#{case_id}/task"
      else
        'task'
      end
    end
  end
end
