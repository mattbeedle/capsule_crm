module CapsuleCRM
  module Inspector
    def inspect
      string = "#<#{self.class.name}:#{self.object_id} "
      fields = self.class.attribute_set.map do |field|
        "#{field.name}: #{self.send(field.name)}"
      end
      string << fields.join(", ") << ">"
    end
  end
end
