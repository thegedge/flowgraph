require "callgraph/recorder"
require "callgraph/version"

module Callgraph
  extend self

  def record
    Callgraph::Recorder.new.record { yield }
  end
end
