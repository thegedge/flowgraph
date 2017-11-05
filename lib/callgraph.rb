require "callgraph/event"
require "callgraph/recorder"
require "callgraph/recorders/stream"
require "callgraph/tracer"
require "callgraph/version"

module Callgraph
  extend self

  def record(recorder)
    Callgraph::Tracer.new(recorder).trace { yield }
  end
end
