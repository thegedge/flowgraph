module Callgraph
  class Recorder
    def record(tracepoint_event)
      raise NotImplementedError("subclasses must implement #record")
    end
  end
end
