# frozen_string_literal: true

module Callgraph
  module Hooks
    module Minitest
      class << self
        def install_hook(recorder)
          tracer = Tracer.new(recorder)
          ext = Module.new
          ext.send(:define_method, :run) do
            tracer.trace { super() }
          end
          ::Minitest::Test.send(:prepend, ext)
        end
      end
    end
  end
end
