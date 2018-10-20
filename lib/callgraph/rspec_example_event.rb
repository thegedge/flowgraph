# frozen_string_literal: true
require "forwardable"

module Callgraph
  class RSpecExampleEvent
    extend Forwardable

    include EventDefaults

    def_delegator :@receiver, :full_description, :method_name
    def_delegator :@receiver, :class, :defined_class

    attr_reader :receiver, :type

    def initialize(example, type)
      @receiver = example
      @type = type
    end

    def source_location
      @source_location ||= receiver.location.split(":")
    end
  end
end
