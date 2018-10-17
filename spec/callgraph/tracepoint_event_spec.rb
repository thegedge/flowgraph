# frozen_string_literal: true

require "spec_helper"

module Callgraph
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
      instance_double(TracePoint, defined_class: defined_class, event: event, method_id: method_name, self: receiver)
    end

    subject { TracepointEvent.new(tp_event) }

    context "when given a TracePoint event for a regular class" do
      it do
        is_expected.to have_attributes(
          receiver_class: TestClass,
          method_string: "Callgraph::TestClass#foo",
          method_type: :instance,
          defined_class_name: "Callgraph::TestClass",
          defined_line_number: 10,
          defined_path: a_string_ending_with("spec/callgraph/tracepoint_event_spec.rb")
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
          method_string: "Callgraph::TestClass#foo (singleton)",
          method_type: :singleton,
          defined_class_name: a_string_matching(/#<Callgraph::TestClass:.*>/),
          defined_line_number: 46,
          defined_path: a_string_ending_with("spec/callgraph/tracepoint_event_spec.rb")
        )
      end
    end

    context "when given a TracePoint event for a class" do
      let(:receiver) { TestClass }
      let(:defined_class) { TestClass.singleton_class }

      it do
        is_expected.to have_attributes(
          receiver_class: TestClass,
          method_string: "Callgraph::TestClass.foo",
          method_type: :class,
          defined_class_name: "Callgraph::TestClass",
          defined_line_number: 7,
          defined_path: a_string_ending_with("spec/callgraph/tracepoint_event_spec.rb")
        )
      end
    end

    context "when given a TracePoint event for a module" do
      let(:receiver) { TestModule }
      let(:defined_class) { TestModule.singleton_class }

      it do
        is_expected.to have_attributes(
          receiver_class: TestModule,
          method_string: "Callgraph::TestModule.foo",
          method_type: :module,
          defined_class_name: "Callgraph::TestModule",
          defined_line_number: 15,
          defined_path: a_string_ending_with("spec/callgraph/tracepoint_event_spec.rb")
        )
      end
    end
  end
end
