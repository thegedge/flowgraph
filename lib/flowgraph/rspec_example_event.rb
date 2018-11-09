# frozen_string_literal: true
require "forwardable"

module Flowgraph
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
      @source_location ||= begin
        path, lineno = receiver.location.split(":")
        [File.expand_path(path), lineno.to_i]
      end
    end
  end
end
