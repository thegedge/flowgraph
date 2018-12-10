# frozen_string_literal: true
require 'pathname'

module Flowgraph
  module Recorders
    class Filtered < Recorder
      class << self
        def only(child_recorder, root)
          glob = File.join(File.expand_path(root), "**")
          new(child_recorder) do |event|
            if defined?(::Minitest::Test)
              # TODO Hack, refactor to not depend on minitest. Here because the :return event for
              #   Minitest::Test#run sometimes seem to have a path outside of the typical filter
              #   (the project path).
              next true if event.defined_class < ::Minitest::Test
            end
            File.fnmatch?(glob, event.defined_path)
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
