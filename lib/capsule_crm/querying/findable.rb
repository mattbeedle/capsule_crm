require_relative 'find_all'
require_relative 'find_one'

module CapsuleCRM
  module Querying
    module Findable
      def self.included(base)
        base.send :include, CapsuleCRM::Querying::Configuration
        base.send :include, CapsuleCRM::Querying::FindAll
        base.send :include, CapsuleCRM::Querying::FindOne
      end
    end
  end
end
