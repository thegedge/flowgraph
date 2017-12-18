module Callgraph
  class Tracer
    def initialize(recorder)
      @last_event = nil
      @tracer = TracePoint.new(:call, :return) do |event|
        case event.event
        when :call
          @last_event = Event.new(event, parent: @last_event)
          recorder.record(@last_event)
        when :return
          @last_event = @last_event.parent
          recorder.record(Event.new(event, parent: @last_event))
        end
      end
    end

    def trace
      @tracer.enable { yield }
    end
  end
end
