require 'active_support/inflector'

module CapsuleCRM
  class HashHelper
    def self.underscore_keys!(hash)
      hash.keys.each do |key|
        hash[key.to_s.underscore] = hash.delete(key)
      end
    end

    def self.camelize_keys!(hash)
      hash.keys.each do |key|
        hash[key.to_s.camelize(:lower)] = hash.delete(key)
      end
    end

    def self.camelize_keys(hash)
      camelize_keys!(hash)
      hash
    end
  end
end
