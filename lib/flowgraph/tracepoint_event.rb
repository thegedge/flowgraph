# frozen_string_literal: true

module Flowgraph
  class TracepointEvent
    extend Forwardable

    include EventDefaults

    def_delegator :@tracepoint_event, :event, :type
    def_delegator :@tracepoint_event, :method_id, :method_name
    def_delegator :@tracepoint_event, :self, :receiver
    def_delegator :@tracepoint_event, :defined_class
    def_delegator :@tracepoint_event, :path, :defined_path
    def_delegator :@tracepoint_event, :lineno, :defined_line_number

    def initialize(tracepoint_event)
      @tracepoint_event = tracepoint_event
    end

    def source_location
      @source_location ||= [@tracepoint_event.path, @tracepoint_event.lineno]
    end
  end
end
