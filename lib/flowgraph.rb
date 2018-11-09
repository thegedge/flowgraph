# frozen_string_literal: true

require "flowgraph/event_defaults"
require "flowgraph/rspec_example_event"
require "flowgraph/stack"
require "flowgraph/tracepoint_event"
require "flowgraph/tracer"
require "flowgraph/version"

require "flowgraph/recorder"
require "flowgraph/recorders/filtered"
require "flowgraph/recorders/sqlite"
require "flowgraph/recorders/stream"

module Flowgraph
  class << self
    def record(recorder)
      Flowgraph::Tracer.new(recorder).trace { yield }
    end
  end
end
