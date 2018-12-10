# frozen_string_literal: true

module Flowgraph
  module Hooks
    module Minitest
      class << self
        def install_hook(recorder)
          tracer = Tracer.new(recorder)

          ext = Module.new
          ext.send(:define_method, :run) do
            # Define a singleton version of the test to reduce scope of tracer
            self.define_singleton_method(self.name) do
              tracer.trace { super() }
            end

            super()
          end

          ::Minitest::Test.send(:prepend, ext)
        end
      end
    end
  end
end
