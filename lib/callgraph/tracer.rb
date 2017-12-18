module Callgraph
  class Tracer
    def initialize(recorder)
      @last_event = nil
      @tracer = TracePoint.new(:call, :return) do |event|
        case event.event
        when :call
          @last_event = Event.new(event, parent: @last_event, start_time: Time.now)
          recorder.record(@last_event)
        when :return
          recorder.record(
            Event.new(event, parent: @last_event.parent, start_time: @last_event.start_time, end_time: Time.now)
          )
          @last_event = @last_event.parent
        end
      end
    end

    def trace
      @tracer.enable { yield }
    end
  end
end
