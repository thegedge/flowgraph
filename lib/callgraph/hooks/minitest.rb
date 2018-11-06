# frozen_string_literal: true

module Callgraph
  module Hooks
    module Minitest
      class << self
        def install_hook(recorder)
          tracer = Tracer.new(recorder)

          ext = Module.new
          ext.send(:define_method, :after_setup) do
            super()
            tracer.start
          end

          ext.send(:define_method, :before_teardown) do
            tracer.stop
            super()
          end

          ::Minitest::Test.send(:prepend, ext)
        end
      end
    end
  end
end
