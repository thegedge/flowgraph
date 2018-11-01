#!/usr/bin/env ruby
# frozen_string_literal: true
require "callgraph"
require "optparse"

options = {
  cluster: false,
  preview: false,
  transitive: false,
  filter: [],
}

op = OptionParser.new do |opts|
  opts.banner = "Usage: dump_calls.rb [options] db_file"

  opts.on("-p", "--preview", "Output PNG and open") do |_|
    options[:preview] = true
  end

  opts.on("-c", "--cluster", "Cluster calls with their receiving class") do |v|
    options[:cluster] = true
  end

  opts.on("-t", "--transitive", String, "Draw edges for the transitive closure") do |v|
    options[:transitive] = true
  end

  opts.on("-f", "--filter=FILTER", String, "Comma-separated list of classes to filter") do |v|
    options[:filter] = v.split(",")
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit 1
  end
end

op.parse!
if ARGV.length != 1
  puts op
  exit 1
end

File.open("callgraph.dot", "wt") do |f|
  f.write("strict digraph callgraph {\n")
  f.write("  node[fontname=\"Source Code Pro\"]\n")
  f.write("  fontname=\"Source Code Pro bold\"\n")

  recorder = Callgraph::Recorders::Sqlite.new(ARGV[0])
  method_calls = recorder.method_calls

  # Cluster the classes together
  if options[:cluster]
    class_methods = method_calls.each_with_object({}) do |mc, classes|
      [mc.source, mc.target].each do |method|
        classes[method.receiver_class] ||= Set.new
        classes[method.receiver_class] << method.to_s
      end
    end

    class_methods.each_with_index do |(clazz, methods), index|
      f.write("  subgraph cluster_#{index} {\n")
      f.write("    label = \"#{clazz}\";\n")
      methods.each do |method|
        f.write("    \"#{method}\";\n")
      end
      f.write("  }\n\n")
    end
  end

  # Now the edges
  method_calls.each do |mc|
    next if mc.transitive && !options[:transitive]
    next if options[:filter].any? do |f|
      mc.source.receiver_class.to_s.include?(f) || mc.target.receiver_class.to_s.include?(f)
    end

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
