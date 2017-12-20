# frozen_string_literal: true

require "spec_helper"

module Callgraph
  RSpec.describe Tracer do
    let(:stream) { StringIO.new }
    let(:recorder) { Recorders::Stream.new(stream) }

    subject { Tracer.new(recorder) }

    # TODO we should really have a recorder that stores all the events and assert against that
    it "should record the callgraph for a given block" do
      subject.trace do
        class Test
          def self.foo
          end

          def benchmark
            yield
          end

          def foo
            benchmark { self.class.foo }
            self.class.foo
          end
        end

        Test.new.foo
      end

      expect(stream.string).to eq(
        <<~CALL_GRAPH
          Callgraph::Test#foo
            Callgraph::Test#benchmark
              Callgraph::Test.foo
            Callgraph::Test.foo
        CALL_GRAPH
      )
    end
  end
end
