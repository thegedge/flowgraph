# frozen_string_literal: true

module Callgraph
  class Tracer
    def initialize(recorder)
      @tracer = TracePoint.new(:call, :return) do |event|
        recorder.record(Event.from_tracepoint_event(event))
      end
    end

    def trace
      @tracer.enable { yield }
    end
  end
end
