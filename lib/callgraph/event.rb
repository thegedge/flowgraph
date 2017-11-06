module Callgraph
  class Event
    extend Forwardable

    def_delegator :@tracepoint_event, :event, :type
    def_delegator :@tracepoint_event, :method_id, :method_name
    def_delegator :@tracepoint_event, :self, :receiver
    def_delegator :@tracepoint_event, :defined_class

    def initialize(tracepoint_event)
      @tracepoint_event = tracepoint_event
    end

    def receiver_class
      @reciver_class ||= method_type == :class ? receiver : receiver.class
    end

    def defined_class_name
      @defined_class_name ||= case method_type
      when :class
        receiver_class.to_s
      when :singleton
        receiver_class.to_s
      when :instance
        defined_class.to_s
      end
    end

    def defined_path
      @defined_path ||= source_location[0]
    end

    def defined_line_number
      @defined_line_number ||= source_location[1]
    end

    def method_string
      @method_string ||= case method_type
      when :class
        "#{receiver_class}.#{method_name}"
      when :singleton
        "#{receiver_class}##{method_name} (singleton)"
      when :instance
        "#{defined_class}##{method_name}"
      end
    end

    def method_type
      @method_type ||= begin
        self_is_class = @tracepoint_event.self.class == Class
        if @tracepoint_event.defined_class.singleton_class?
          self_is_class ? :class : :singleton
        elsif self_is_class
          :class
        else
          :instance
        end
      end
    end

    private

    def source_location
      @source_location ||= defined_class.instance_method(method_name).source_location
    end
  end
end