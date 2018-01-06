# frozen_string_literal: true

module Callgraph
  module Hooks
    class << self
      def install_rspec_hooks(recorder)
        tracer = Tracer.new(rspec_filter(recorder))

        RSpec.configure do |config|
          config.around(:each) do |procsy|
            method_name = procsy.example.full_description
            receiver = procsy.example
            defined_class = procsy.example.class
            source_location = procsy.example.location.split(":")

            tracer.inject_event(RSpecExampleEvent.new(procsy.example, :call))
            tracer.trace { procsy.run }
            tracer.inject_event(RSpecExampleEvent.new(procsy.example, :return))
          end
        end
      end

      private

      def rspec_filter(recorder)
        Recorders::Filtered.new(recorder) do |event|
          next true if event.defined_class == RSpec::Core::Example
          next false if event.defined_class.to_s.start_with?('RSpec::')
          true
        end
      end
    end
  end
end
