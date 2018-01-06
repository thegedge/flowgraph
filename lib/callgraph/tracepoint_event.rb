# frozen_string_literal: true

module Callgraph
  class TracepointEvent
    extend Forwardable

    include EventDefaults

    def_delegator :@tracepoint_event, :event, :type
    def_delegator :@tracepoint_event, :method_id, :method_name
    def_delegator :@tracepoint_event, :self, :receiver
    def_delegator :@tracepoint_event, :defined_class

    def initialize(tracepoint_event)
      @tracepoint_event = tracepoint_event
    end
  end
end
