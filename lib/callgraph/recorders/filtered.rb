# frozen_string_literal: true

module Callgraph
  module Recorders
    class Filtered < Recorder
      class << self
        def exclude_system(child_recorder)
          new(child_recorder) do |event|
            next false if event.defined_path.include?(".gem")
            next false if event.defined_path.start_with?("/opt")
            next false if event.defined_path.include?("/spec/")
            true
          end
        end
      end

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
