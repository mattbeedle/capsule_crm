module CapsuleCRM
  class User
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations
    include CapsuleCRM::Persistable
    include CapsuleCRM::Querying::FindAll
    include CapsuleCRM::Serializable

    attribute :username, String
    attribute :name, String
    attribute :currency, String
    attribute :timezone, String
    attribute :logged_in, Boolean

    belongs_to :party, class_name: 'CapsuleCRM::Party'

    def id
      username
    end

    def self.find_by_username(username)
      all.select { |user| user.username == username }.first
    end
  end
end