# frozen_string_literal: true

module Callgraph
  class Tracer
    def initialize(recorder)
      @recorder = recorder
      @tracer = TracePoint.new(:call, :return) do |event|
        @recorder.record(TracepointEvent.new(event))
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
