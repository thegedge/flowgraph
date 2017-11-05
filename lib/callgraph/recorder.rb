module Callgraph
  class Recorder
    def record(tracepoint_event)
      raise NotImplementedError("subclasses must implement #record")
    end

    protected

    def classify(tp)
      self_is_class = tp.self.class == Class
      if tp.defined_class.singleton_class?
        self_is_class ? :singleton_class : :singleton_instance
      elsif self_is_class
        :class
      else
        :instance
      end
    end
  end
end
