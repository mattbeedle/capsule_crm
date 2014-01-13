module CapsuleCRM
  module Persistence
    module Deletable
      def destroy
        self.id = nil if CapsuleCRM::Connection.delete(build_destroy_path)
        self
      end

      def build_destroy_path
        "/api/#{self.class.connection_options.destroy.call(self)}"
      end
    end
  end
end
