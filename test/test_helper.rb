$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "callgraph"

require "minitest"
require "minitest/spec"
require "mocha/mini_test"

Minitest.autorun
