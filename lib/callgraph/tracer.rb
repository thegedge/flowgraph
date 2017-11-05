module Callgraph
  class Tracer
    def initialize(recorder)
      @tracer = TracePoint.new(:call, :return) do |event|
        recorder.record(event)
      end
    end

    def trace
      @tracer.enable
      yield
      @tracer.disable
    end
  end
end
