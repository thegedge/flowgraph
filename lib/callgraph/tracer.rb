# frozen_string_literal: true

module Callgraph
  class Tracer
    def initialize(recorder)
      @recorder = recorder
      @tracer = TracePoint.new(:call, :return) do |event|
        @recorder.record(Event.from_tracepoint_event(event))
      end
    end

    def inject_event(event)
      @recorder.record(event)
    end

    def trace
      @tracer.enable { yield }
    end
  end
end
