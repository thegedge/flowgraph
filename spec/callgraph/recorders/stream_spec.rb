# frozen_string_literal: true

require "spec_helper"

module Callgraph
  module Recorders
    RSpec.describe(Stream) do
      let(:stream) { StringIO.new }
      let(:call_event_a) { instance_double(Event, type: :call, method_string: "Test.foo") }
      let(:call_event_b) { instance_double(Event, type: :call, method_string: "MyCoolClass#foo") }
      let(:return_event) { instance_double(Event, type: :return) }

      subject { Stream.new(stream) }

      describe "#record" do
        it "writes a single event" do
          subject.record(call_event_a)

          expect(stream.string).to eq("Test.foo\n")
        end

        it "writes multiple events" do
          subject.record(call_event_a)
          subject.record(return_event)
          subject.record(call_event_b)

          expect(stream.string).to eq(
            <<~CALL_GRAPH
              Test.foo
              MyCoolClass#foo
            CALL_GRAPH
          )
        end

        it "writes hierarchical events" do
          subject.record(call_event_a)
          subject.record(call_event_b)
          subject.record(call_event_a)
          subject.record(return_event)
          subject.record(return_event)
          subject.record(call_event_a)
          subject.record(return_event)
          subject.record(return_event)
          subject.record(call_event_b)
          subject.record(call_event_a)

          expect(stream.string).to eq(
            <<~CALL_GRAPH
              Test.foo
                MyCoolClass#foo
                  Test.foo
                Test.foo
              MyCoolClass#foo
                Test.foo
            CALL_GRAPH
          )
        end
      end
    end
  end
end
