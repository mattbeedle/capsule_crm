module CapsuleCRM
  class CustomField
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :id, Integer
    attribute :date, DateTime
    attribute :tag, String
    attribute :boolean, Boolean
    attribute :text, String
    attribute :data_tag, String

    def self.create(attributes = {})
    end

    def self.create!(attribute = {})
    end

    def save
    end

    def save!
    end

    def destroy
    end

    private

    def create_record
    end

    def update_record
    end
  end
end