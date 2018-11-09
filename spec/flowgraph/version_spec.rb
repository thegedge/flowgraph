# frozen_string_literal: true

require "spec_helper"

RSpec.describe Flowgraph do
  context "::VERSION" do
    it { expect(Flowgraph::VERSION).to_not be_nil }
  end
end
