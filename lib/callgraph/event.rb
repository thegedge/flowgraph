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

    def method_string
      @method_string ||= case method_type
      when :class
        "#{defined_class}.#{method_name}"
      when :singleton_class
        "#{receiver}(s).#{method_name}"
      when :singleton_instance
        "#{receiver.class}(s)##{method_name}"
      when :instance
        "#{defined_class}##{method_name}"
      end
    end

    def method_type
      @method_type ||= begin
        self_is_class = @tracepoint_event.self.class == Class
        if @tracepoint_event.defined_class.singleton_class?
          self_is_class ? :singleton_class : :singleton_instance
        elsif self_is_class
          :class
        else
          :instance
        end
      end
    end
  end
end
