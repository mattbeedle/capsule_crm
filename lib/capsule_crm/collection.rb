module CapsuleCRM::Collection
  extend ActiveSupport::Concern

  module ClassMethods
    def init_collection(*collection)
      collection.flatten.compact.map { |item| new item }
    end
  end
end
