# frozen_string_literal: true

require "spec_helper"

module Callgraph
  module Recorders
    DB_PATH = "tmp/sqlite_test"

    RSpec.describe(Sqlite) do
      # TODO have a shared pool of instance doubles for recorder specs
      let(:call_event_a) do
        instance_double(
          TracepointEvent,
          type: :call,
          method_name: "foo",
          receiver_class_name: "Foo",
          defined_class_name: "Test",
          defined_path: "spec/callgraph/recorders/sqlite_spec.rb",
          defined_line_number: 5,
          method_type: :class
        )
      end

      let(:method_a) { Sqlite::Method.new("foo", "Foo", "Test", "spec/callgraph/recorders/sqlite_spec.rb", 5, :class) }

      let(:call_event_b) do
        instance_double(
          TracepointEvent,
          type: :call,
          method_name: "foo",
          receiver_class_name: "Bar",
          defined_class_name: "MyCoolClass",
          defined_path: "spec/callgraph/recorders/sqlite_spec.rb",
          defined_line_number: 13,
          method_type: :instance
        )
      end

      let(:method_b) do
        Sqlite::Method.new("foo", "Bar", "MyCoolClass", "spec/callgraph/recorders/sqlite_spec.rb", 13, :instance)
      end

      let(:return_event) { instance_double(TracepointEvent, type: :return) }

      before(:each) { subject.database.transaction }
      after(:each) { subject.database.rollback }

      describe "#record" do
        subject { Sqlite.new(DB_PATH) }

        it "writes a single event" do
          subject.record(call_event_a)

          expect(subject.methods.values).to eq([method_a])
          expect(subject.method_calls.to_a).to be_empty
        end

        it "writes multiple events" do
          subject.record(call_event_a)
          subject.record(return_event)
          subject.record(call_event_a)
          subject.record(return_event)
          subject.record(call_event_b)

          expect(subject.methods.values).to eq([method_a, method_b])
          expect(subject.method_calls.to_a).to be_empty
        end

        it "writes hierarchical events" do
          subject.record(call_event_a)
          subject.record(call_event_b)
          subject.record(call_event_a)
          subject.record(return_event)
          subject.record(return_event)
          subject.record(call_event_b)
          subject.record(return_event)
          subject.record(return_event)
          subject.record(call_event_b)
          subject.record(call_event_a)

          expect(subject.methods.values).to eq([method_a, method_b])
          expect(subject.method_calls.to_a).to contain_exactly(
            Sqlite::MethodCall.new(method_a, method_b, false),
            Sqlite::MethodCall.new(method_b, method_a, false),
            Sqlite::MethodCall.new(method_a, method_a, true)
          )
        end
      end
    end
  end
end
