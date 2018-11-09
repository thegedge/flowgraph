# frozen_string_literal: true
require "forwardable"

module Flowgraph
  class Stack
    extend Forwardable

    def initialize(key)
      @stack_key = "stack_#{key}_#{__id__}"
    end

    def_delegators :current, :[], :<<, :pop, :length, :reverse, :last, :clone, :inspect

    def current
      Thread.current[@stack_key] ||= []
    end
  end
end
