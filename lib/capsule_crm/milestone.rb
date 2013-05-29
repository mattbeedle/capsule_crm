module CapsuleCRM
  class Milestone
    include Virtus

    attribute :id, Integer
    attribute :name, String
    attribute :description, String
    attribute :probability, Float
    attribute :complete, Boolean

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

    private

    def self.init_collection(collection)
      CapsuleCRM::ResultsProxy.new(
        collection.map { |attributes| new attributes }
      )
    end
  end
end