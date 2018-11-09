# frozen_string_literal: true

module Flowgraph
  module Hooks
    module RSpec
      class << self
        def install_hook(recorder)
          tracer = Tracer.new(recorder)

          ::RSpec.configure do |config|
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
      end
    end
  end
end
