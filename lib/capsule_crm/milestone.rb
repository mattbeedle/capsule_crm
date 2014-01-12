module CapsuleCRM
  class Milestone
    include Virtus
    include CapsuleCRM::Collection
    include CapsuleCRM::Serializable
    include ActiveModel::Validations

    attribute :id, Integer
    attribute :name, String
    attribute :description, String
    attribute :probability, Float
    attribute :complete, Boolean

    validates :id, numericality: { allow_blank: true }

    def self.all
      CapsuleCRM::Serializer.normalize_collection(
        self, CapsuleCRM::Connection.get('/api/opportunity/milestones')
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
