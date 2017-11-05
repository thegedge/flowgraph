module Callgraph
  module Recorders
    class Stream < Recorder
      def initialize(stream)
        @stream = stream
        @stack_depth = 0
      end

      def record(tracepoint_event)
        case tracepoint_event.event
        when :call
          method_string = case classify(tracepoint_event)
          when :class
            "#{tracepoint_event.defined_class}.#{tracepoint_event.method_id}"
          when :singleton_class
            "#{tracepoint_event.self}(s).#{tracepoint_event.method_id}"
          when :singleton_instance
            "#{tracepoint_event.self.class}(s)##{tracepoint_event.method_id}"
          when :instance
            "#{tracepoint_event.defined_class}##{tracepoint_event.method_id}"
          end

          @stream.write("  " * @stack_depth)
          @stream.write(method_string)
          @stream.write("\n")

          @stack_depth += 1
        else
          @stack_depth -= 1
        end
      end
    end
  end
end

