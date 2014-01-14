module CapsuleCRM
  module Gettable
    extend ActiveSupport::Concern

    module ClassMethods
      def get(path)
        CapsuleCRM::Connection.get(path)
      end
    end
  end
end
