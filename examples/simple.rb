require 'callgraph'

class A
  def initialize
  end

  def foo
  end

  def bar
    foo
  end
end

class B < A
  def foo
    baz
  end
end

class C < A
  def foo
    super
  end

  def bar
    foo
    super
    self.class.baz
  end

  class << self
    def baz
    end
  end
end

recorder = Callgraph::Recorders::Stream.new(STDOUT)

Callgraph.record(recorder) do
  b = B.new
  def b.baz
  end

  b.bar
end

puts
Callgraph.record(recorder) { C.new.bar }
