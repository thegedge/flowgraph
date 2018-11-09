# frozen_string_literal: true

require "spec_helper"

module Flowgraph
  RSpec.describe(Recorder) do
    context "#record" do
      it "must respond" do
        expect { should respond_to(:record).with(1).arguments }
      end

      it "must raise NotImplementedError" do
        expect { subject.record(nil) }.to raise_error(NotImplementedError)
      end
    end
  end
end
