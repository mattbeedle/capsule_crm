module CapsuleCRM
  class Milestone
    include Virtus
    include CapsuleCRM::Collection
    include ActiveModel::Validations

    attribute :id, Integer
    attribute :name, String
    attribute :description, String
    attribute :probability, Float
    attribute :complete, Boolean

    validates :id, numericality: { allow_blank: true }

    def self.all
      init_collection(
        CapsuleCRM::Connection.
          get('/api/opportunity/milestones')['milestones']['milestone']
      )
    end

    def self.find(id)
      all.select { |item| item.id == id }.first
    end

    def self.find_by_name(name)
      all.select { |item| item.name == name }.first
    end
  end
end
