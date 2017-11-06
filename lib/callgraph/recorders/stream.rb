module Callgraph
  module Recorders
    class Stream < Recorder
      def initialize(stream)
        @stream = stream
        @stack_depth = 0
      end

      def record(event)
        case event.type
        when :call
          @stream.write("  " * @stack_depth)
          @stream.write("#{event.method_string}")
          @stream.write("\n")
          @stack_depth += 1
        else
          @stack_depth -= 1
        end
      end
    end
  end
end
