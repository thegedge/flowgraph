# frozen_string_literal: true

require "spec_helper"

RSpec.describe Callgraph do
  context "::VERSION" do
    it { expect(Callgraph::VERSION).to_not be_nil }
  end
end
