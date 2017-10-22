module Callgraph
  class Recorder
    def initialize
      @stack_depth = 0
      @tracer = TracePoint.new(:call, :return) do |tp|
        case tp.event
        when :call
          print("  " * @stack_depth)

          case classify(tp)
          when :class
            puts("#{tp.defined_class}.#{tp.method_id}")
          when :singleton_class
            puts("#{tp.self}(s).#{tp.method_id}")
          when :singleton_instance
            puts("#{tp.self.class}(s)##{tp.method_id}")
          when :instance
            puts("#{tp.defined_class}##{tp.method_id}")
          end

          @stack_depth += 1
        else
          @stack_depth -= 1
        end
      end
    end

    def record
      @tracer.enable
      yield
      @tracer.disable
    end

    private

    def classify(tp)
      is_class = tp.self.class == Class
      if tp.defined_class.singleton_class?
        is_class ? :singleton_class : :singleton_instance
      elsif is_class
        :class
      else
        :instance
      end
    end
  end
end
