# frozen_string_literal: true

require "spec_helper"

module Flowgraph
  module Recorders
    RSpec.describe(Filtered) do
      let(:test_recorder) { double }

      context "given block returns true" do
        subject do
          Filtered.new(test_recorder) { true }
        end

        describe "#record" do
          it "calls the child recorder's #record" do
            expect(test_recorder).to receive(:record).exactly(3)

            subject.record(1)
            subject.record(2)
            subject.record(3)
          end
        end
      end

      context "given block returns false" do
        subject do
          Filtered.new(test_recorder) { false }
        end

        describe "#record" do
          it "does not call the child recorder's #record" do
            expect(test_recorder).to receive(:record).never

            subject.record(1)
            subject.record(2)
            subject.record(3)
          end
        end
      end
    end
  end
end
