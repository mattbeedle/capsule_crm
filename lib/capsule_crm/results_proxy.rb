module CapsuleCRM
  class ResultsProxy < BasicObject

    def initialize(target)
      @target = target
    end

    protected

    def method_missing(name, *args, &block)
      target.send(name, *args, &block)
    end

    def target
      @target ||= []
    end
  end
end
