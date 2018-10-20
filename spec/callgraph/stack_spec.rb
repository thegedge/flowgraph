# frozen_string_literal: true
require "spec_helper"

module Callgraph
  RSpec.describe Stack do
    subject { Stack.new("stack_test") }

    def d
    end

    def c
      Fiber.yield
      d
    end

    def b
      f = Fiber.new { c }
      f.resume
      d
      f.resume
    end

    def a
      t = Thread.new { b }
      t.join
    end

    module Recorders
      class StackTest < Recorder
        attr_reader :stacks

        def initialize(stack)
          @stack = stack
          @stacks = []
        end

        def record(event)
          case event.type
          when :call
            @stack << event.method_name
            @stacks << @stack.clone
          when :return
            @stack.pop
            @stacks << @stack.clone
          end
        end
      end
    end

    it "should separate stacks of threads and fibers" do
      recorder = Recorders::StackTest.new(subject)
      Tracer.new(recorder).trace { a }

      expect(recorder.stacks).to eq([
        [:a],      # main
        [:b],      # thread
        [:c],      # fiber
        [:b, :d],  # thread
        [:b],      # thread
        [:c, :d],  # fiber
        [:c],      # fiber
        [],        # fiber
        [],        # thread
        []         # main
      ])
    end
  end
end
