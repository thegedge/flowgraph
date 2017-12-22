# frozen_string_literal: true

module Callgraph
  module Hooks
    class << self
      def install_rspec_hooks(recorder)
        tracer = Tracer.new(recorder)
        RSpec.configure do |config|
          config.around(:each) do |example|
            tracer.trace { example.run }
          end
        end
      end
    end
  end
end
