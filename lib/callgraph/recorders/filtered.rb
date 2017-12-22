# frozen_string_literal: true

module Callgraph
  module Recorders
    class Filtered < Recorder
      def initialize(recorder, &blk)
        @recorder = recorder
        @filter = blk
      end

      def record(event)
        @recorder.record(event) if @filter.call(event)
      end
    end
  end
end
