require "test_helper"

module Callgraph
  describe Callgraph do
    describe "::VERSION" do
      it { expect(::Callgraph::VERSION).wont_be_nil }
    end
  end
end
