require 'test_helper'

module Callgraph
  class TestClass
    def self.foo
    end

    def foo
    end
  end

  describe Event do
    let(:parent) { nil }
    let(:start_time) { Time.parse('2017-12-12 00:00:00.000 UTC') }
    let(:end_time) { start_time ? start_time + Rational(33, 32) : nil }

    let(:tp_event) { stub(defined_class: defined_class, event: event, method_id: method_name, self: receiver)  }
    let(:defined_class) { TestClass }
    let(:receiver) { defined_class.new }
    let(:event) { :call }
    let(:method_name) { :foo }

    subject { Event.new(tp_event, start_time: start_time, end_time: end_time, parent: parent) }

    describe :time_taken do
      let(:tp_event) { stub }

      describe "when given a start and end time" do
        it "must return difference in start and end times" do
          subject.time_taken.must_equal 1.03125
        end
      end

      describe "with no start time" do
        let(:start_time) { nil }

        it "must return nil" do
          subject.time_taken.must_be_nil
        end
      end

      describe "with no end time" do
        let(:end_time) { nil }

        it { expect(subject.time_taken).must_be_nil }
      end
    end

    describe "when given a TracePoint event for a regular class" do
      it { expect(subject.receiver_class).must_equal TestClass }
      it { expect(subject.method_string).must_equal 'Callgraph::TestClass#foo' }
      it { expect(subject.method_type).must_equal :instance }
      it { expect(subject.defined_class_name).must_equal 'Callgraph::TestClass' }
      it { expect(subject.defined_line_number).must_equal 8 }
      it do
        expect(Pathname.new(subject.defined_path).realdirpath)
          .must_equal(Pathname.new('test/unit/callgraph/event_test.rb').realdirpath)
      end
    end

    describe "when given a TracePoint event for a singleton class" do
      let(:receiver) do
        TestClass.new.tap do |tc|
          def tc.foo
          end
        end
      end

      let(:defined_class) { receiver.singleton_class }

      it { expect(subject.receiver_class).must_equal TestClass }
      it { expect(subject.method_string).must_equal 'Callgraph::TestClass#foo (singleton)' }
      it { expect(subject.method_type).must_equal :singleton }
      it { expect(subject.defined_class_name).must_match %r{#<Callgraph::TestClass:.*>} }
      it { expect(subject.defined_line_number).must_equal 64 }
      it do
        expect(Pathname.new(subject.defined_path).realdirpath)
          .must_equal(Pathname.new('test/unit/callgraph/event_test.rb').realdirpath)
      end
    end

    describe "when given a TracePoint event for a class" do
      let(:receiver) { TestClass }
      let(:defined_class) { TestClass.singleton_class }

      it { expect(subject.receiver_class).must_equal TestClass }
      it { expect(subject.method_string).must_equal 'Callgraph::TestClass.foo' }
      it { expect(subject.method_type).must_equal :class }
      it { expect(subject.defined_class_name).must_equal 'Callgraph::TestClass' }
      it { expect(subject.defined_line_number).must_equal 5 }
      it do
        expect(Pathname.new(subject.defined_path).realdirpath).must_equal(
          Pathname.new('test/unit/callgraph/event_test.rb').realdirpath
        )
      end
    end
  end
end
