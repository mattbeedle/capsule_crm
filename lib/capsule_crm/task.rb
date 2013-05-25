module CapsuleCRM
  class Task
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations::BelongsTo

    attribute :id, Integer
    attribute :due_date, Date
    attribute :due_date_time, DateTime
    attribute :category, String
    attribute :description, String
    attribute :detail, String

    belongs_to :party, class_name: 'CapsuleCRM::Party'
    belongs_to :opportunity, class_name: 'CapsuleCRM::Opportunity'
    belongs_to :case, class_name: 'CapsuleCRM::Case'
    belongs_to :owner, class_name: 'CapsuleCRM::User'

    validates :description, presence: true
    validates :due_date, presence: { unless: :due_date_time }
    validates :due_date_time, presence: { unless: :due_date }

    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end

    def owner=(user)
      user = CapsuleCRM::User.find_by_username(user) if user.is_a?(String)
      @owner = user
      self
    end

    def self.all(options = {})
      init_collection(
        CapsuleCRM::Connection.get('/api/tasks', options)['tasks']['task']
      )
    end

    def self.find(id)
      new CapsuleCRM::Connection.get("/api/task/#{id}")['task']
    end

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
        save
      else
        raise CapsuleCRM::Errors::RecordInvalid.new(self)
      end
    end

    def destroy
      self.id = nil if CapsuleCRM::Connection.delete("/api/task/#{id}")
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

    def self.categories
      CapsuleCRM::Connection.
        get('/api/task/categories')['taskCategories']['taskCategory']
    end

    def new_record?
      !id
    end

    def persisted?
      !new_record?
    end

    def to_capsule_json
      {
        task: CapsuleCRM::HashHelper.camelize_keys(capsule_attributes)
      }.stringify_keys
    end

    private

    def capsule_attributes
      { description: description, category: category }.tap do |attrs|
        attrs.merge!(owner: owner.username) if owner
        attrs.merge!(due_date: due_date.to_s(:db)) if due_date
        attrs.merge!(due_date_time: due_date_time.to_s(:db)) if due_date_time
      end
    end

    def self.init_collection(collection)
      CapsuleCRM::ResultsProxy.new(collection.map { |item| new item })
    end

    def create_record
      self.attributes = CapsuleCRM::Connection.post(
        '/api/task', to_capsule_json
      )
      self
    end

    def update_record
      CapsuleCRM::Connection.put("/api/task/#{id}", to_capsule_json)
      self
    end
  end
end