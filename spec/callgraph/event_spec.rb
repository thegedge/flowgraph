# frozen_string_literal: true

require "spec_helper"

module Callgraph
  class TestClass
    def self.foo
    end

    def foo
    end
  end

  RSpec.describe(Event) do
    let(:parent) { nil }
    let(:start_time) { Time.parse("2017-12-12 00:00:00.000 UTC") }
    let(:end_time) { start_time ? start_time + Rational(33, 32) : nil }

    let(:defined_class) { TestClass }
    let(:receiver) { defined_class.new }
    let(:event) { :call }
    let(:method_name) { :foo }
    let(:tp_event) do
      instance_double(TracePoint, defined_class: defined_class, event: event, method_id: method_name, self: receiver)
    end

    subject { Event.new(tp_event, start_time: start_time, end_time: end_time, parent: parent) }

    context "#time_taken" do
      context "when given a start and end time" do
        it { expect(subject.time_taken).to be_within(1e-10).of(1.03125) }
      end

      context "with no start time" do
        let(:start_time) { nil }

        it { expect(subject.time_taken).to be_nil }
      end

      context "with no end time" do
        let(:end_time) { nil }

        it { expect(subject.time_taken).to be_nil }
      end
    end

    context "when given a TracePoint event for a regular class" do
      it do
        is_expected.to have_attributes(
          receiver_class: TestClass,
          method_string: "Callgraph::TestClass#foo",
          method_type: :instance,
          defined_class_name: "Callgraph::TestClass",
          defined_line_number: 10,
          defined_path: a_string_ending_with("spec/callgraph/event_spec.rb")
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
          defined_line_number: 63,
          defined_path: a_string_ending_with("spec/callgraph/event_spec.rb")
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
          defined_path: a_string_ending_with("spec/callgraph/event_spec.rb")
        )
      end
    end
  end
end
