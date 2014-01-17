module CapsuleCRM
  module Gettable
    extend ActiveSupport::Concern

    module ClassMethods
      def get(path, options = {})
        CapsuleCRM::Connection.get(path, options)
      end
    end
  end
end
