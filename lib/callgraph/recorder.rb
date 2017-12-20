# frozen_string_literal: true

module Callgraph
  class Recorder
    def record(_tracepoint_event)
      raise NotImplementedError, "subclasses must implement #record"
    end
  end
end
