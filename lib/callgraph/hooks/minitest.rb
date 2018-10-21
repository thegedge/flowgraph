# frozen_string_literal: true

module Callgraph
  module Hooks
    module Minitest
      class << self
        def install_hook(recorder)
          tracer = Tracer.new(minitest_filter(recorder))
          ext = Module.new
          ext.send(:define_method, :run) do
            tracer.trace { super() }
          end
          ::Minitest::Test.send(:prepend, ext)
        end

        private

        EXCLUDE_METHODS = Set.new([:setup, :on_signal])
        private_constant :EXCLUDE_METHODS

        def minitest_filter(recorder)
          Recorders::Filtered.new(recorder) do |event|
            next false if event.receiver_class.to_s == "Minitest"
            next false if event.defined_class.to_s.start_with?("Minitest::")
            next false if event.receiver_class <= ::Minitest::Test && EXCLUDE_METHODS.include?(event.method_name)
            true
          end
        end
      end
    end
  end
end
