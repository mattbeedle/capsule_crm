module CapsuleCRM
  class User
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include CapsuleCRM::Associations::BelongsTo

    attribute :username, String
    attribute :name, String
    attribute :currency, String
    attribute :timezone, String
    attribute :logged_in, Boolean

    belongs_to :party, class_name: 'CapsuleCRM::Party'

    # Public: Retrieve all users from CapsuleCRM
    #
    # Examples:
    #
    # CapsuleCRM::User.all
    #
    # Returns a CapsuleCRM::ResultsProxy of CapsuleCRM::User objects
    def self.all
      CapsuleCRM::ResultsProxy.new(
        CapsuleCRM::Connection.get('/api/users')['users']['user'].map do |item|
          new item
        end
      )
    end

    def self.find_by_username(username)
      all.select { |user| user.username == username }.first
    end
  end
end