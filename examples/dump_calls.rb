# frozen_string_literal: true
require "callgraph"
require "optparse"

options = {
  preview: false,
  transitive: false,
  filter: [],
}

OptionParser.new do |opts|
  opts.banner = "Usage: dump_calls.rb [options] file"

  opts.on("-p", "--preview", "Output PNG and open") do |_|
    options[:preview] = true
  end

  opts.on("-t", "--transitive", String, "Draw edges for the transitive closure") do |v|
    options[:transitive] = true
  end

  opts.on("-f", "--filter=FILTER", String, "Comma-separated list of classes to filter") do |v|
    options[:filter] = v.split(",")
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

File.open("callgraph.dot", "wt") do |f|
  f.write("digraph callgraph {")

  recorder = Callgraph::Recorders::Sqlite.new(ARGV[0])
  recorder.method_calls.each do |mc|
    next if options[:filter].include?(mc.source.class)
    next if mc.transitive && !options[:transitive]

    f.write("  \"#{mc.source}\" -> \"#{mc.target}\"")
    f.write(" [style=dotted]") if mc.transitive
    f.write(";\n")
  end

  f.write("}\n")
end

if options[:preview]
  `dot -Tpng callgraph.dot > callgraph.png`
  `open callgraph.png`
end
