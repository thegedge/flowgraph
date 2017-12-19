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
    let(:start_time) { Time.parse('2017-12-12 00:00:00.000 UTC') }
    let(:end_time) { start_time ? start_time + Rational(33, 32) : nil }

    let(:defined_class) { TestClass }
    let(:receiver) { defined_class.new }
    let(:event) { :call }
    let(:method_name) { :foo }
    let(:tp_event) do
      instance_double(TracePoint, defined_class: defined_class, event: event, method_id: method_name, self: receiver)
    end

    subject { Event.new(tp_event, start_time: start_time, end_time: end_time, parent: parent) }

    context :time_taken do
      context "when given a start and end time" do
        it "must return difference in start and end times" do
          expect(subject.time_taken).to be_within(1e-10).of(1.03125)
        end
      end

      context "with no start time" do
        let(:start_time) { nil }

        it "must return nil" do
          expect(subject.time_taken).to be_nil
        end
      end

      context "with no end time" do
        let(:end_time) { nil }

        it { expect(subject.time_taken).to be_nil }
      end
    end

    context "when given a TracePoint event for a regular class" do
      it { expect(subject.receiver_class).to eq(TestClass) }
      it { expect(subject.method_string).to eq('Callgraph::TestClass#foo') }
      it { expect(subject.method_type).to eq(:instance) }
      it { expect(subject.defined_class_name).to eq('Callgraph::TestClass') }
      it { expect(subject.defined_line_number).to eq(8) }
      it do
        expect(Pathname.new(subject.defined_path).realdirpath).to(
          eq(Pathname.new('spec/unit/callgraph/event_spec.rb').realdirpath)
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

      it { expect(subject.receiver_class).to eq(TestClass) }
      it { expect(subject.method_string).to eq('Callgraph::TestClass#foo (singleton)') }
      it { expect(subject.method_type).to eq(:singleton) }
      it { expect(subject.defined_class_name).to match(/#<Callgraph::TestClass:.*>/) }
      it { expect(subject.defined_line_number).to eq(65) }
      it do
        expect(Pathname.new(subject.defined_path).realdirpath).to(
          eq(Pathname.new('spec/unit/callgraph/event_spec.rb').realdirpath)
        )
      end
    end

    context "when given a TracePoint event for a class" do
      let(:receiver) { TestClass }
      let(:defined_class) { TestClass.singleton_class }

      it { expect(subject.receiver_class).to eq(TestClass) }
      it { expect(subject.method_string).to eq('Callgraph::TestClass.foo') }
      it { expect(subject.method_type).to eq(:class) }
      it { expect(subject.defined_class_name).to eq('Callgraph::TestClass') }
      it { expect(subject.defined_line_number).to eq(5) }
      it do
        expect(Pathname.new(subject.defined_path).realdirpath).to(
          eq(Pathname.new('spec/unit/callgraph/event_spec.rb').realdirpath)
        )
      end
    end
  end
end
