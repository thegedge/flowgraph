# frozen_string_literal: true

require "spec_helper"

module Flowgraph
  class TestClass
    def self.foo
    end

    def foo
    end
  end

  module TestModule
    def self.foo
    end
  end

  RSpec.describe(TracepointEvent) do
    let(:defined_class) { TestClass }
    let(:receiver) { defined_class.new }
    let(:event) { :call }
    let(:method_name) { :foo }
    let(:tp_event) do
      path, line = receiver.method(method_name).source_location
      instance_double(
        TracePoint,
        event: event,
        method_id: method_name,
        self: receiver,
        defined_class: defined_class,
        path: path,
        lineno: line,
      )
    end

    subject { TracepointEvent.new(tp_event) }

    context "when given a TracePoint event for a regular class" do
      it do
        is_expected.to have_attributes(
          receiver_class: TestClass,
          method_string: "Flowgraph::TestClass#foo",
          method_type: :instance,
          defined_class_name: "Flowgraph::TestClass",
          defined_line_number: TestClass.instance_method(:foo).source_location.last,
          defined_path: a_string_ending_with("spec/flowgraph/tracepoint_event_spec.rb")
        )
      end
    end

    context "when given a TracePoint event for a singleton class" do
      let(:receiver) do
        TestClass.new.tap do |tc|
          def tc.foo
          end
        end
      end

      let(:defined_class) { receiver.singleton_class }

      it do
        is_expected.to have_attributes(
          receiver_class: TestClass,
          method_string: "Flowgraph::TestClass#foo (singleton)",
          method_type: :singleton,
          defined_class_name: "Flowgraph::TestClass",
          defined_line_number: receiver.method(:foo).source_location.last,
          defined_path: a_string_ending_with("spec/flowgraph/tracepoint_event_spec.rb")
        )
      end
    end

    context "when given a TracePoint event for a class" do
      let(:receiver) { TestClass }
      let(:defined_class) { TestClass.singleton_class }

      it do
        is_expected.to have_attributes(
          receiver_class: TestClass,
          method_string: "Flowgraph::TestClass.foo",
          method_type: :class,
          defined_class_name: "Flowgraph::TestClass",
          defined_line_number: TestClass.method(:foo).source_location.last,
          defined_path: a_string_ending_with("spec/flowgraph/tracepoint_event_spec.rb")
        )
      end
    end

    context "when given a TracePoint event for a module" do
      let(:receiver) { TestModule }
      let(:defined_class) { TestModule.singleton_class }

      it do
        is_expected.to have_attributes(
          receiver_class: TestModule,
          method_string: "Flowgraph::TestModule.foo",
          method_type: :module,
          defined_class_name: "Flowgraph::TestModule",
          defined_line_number: TestModule.method(:foo).source_location.last,
          defined_path: a_string_ending_with("spec/flowgraph/tracepoint_event_spec.rb")
        )
      end
    end
  end
end
