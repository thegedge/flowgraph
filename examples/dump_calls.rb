#!/usr/bin/env ruby
# frozen_string_literal: true
require "callgraph"
require "optparse"

options = {
  output: false,
  cluster: false,
  preview: false,
  transitive: false,
  include: nil,
  exclude: nil,
  subtrees: nil,
}

op = OptionParser.new do |opts|
  opts.banner = "Usage: dump_calls.rb [options] db_file"

  opts.on("-o", "--output", "Output PNG to callgraph.png") do |_|
    options[:output] = true
  end

  opts.on("-p", "--preview", "Output PNG and open") do |_|
    options[:preview] = true
  end

  opts.on("-c", "--cluster", "Cluster calls with their receiving class") do |v|
    options[:cluster] = true
  end

  opts.on("-t", "--transitive", String, "Draw edges for the transitive closure") do |v|
    options[:transitive] = true
  end

  opts.on("--include=REGEX", Regexp, "Only include nodes that match this regex") do |v|
    options[:include] = v
  end

  opts.on("--exclude=REGEX", Regexp, "Exclude nodes that match this regex") do |v|
    options[:exclude] = v
  end

  opts.on("--subtrees=REGEX", Regexp, "Only include nodes that are rooted at a node that matches this regex") do |v|
    options[:subtrees] = v
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
  f.write("  node [fontname=\"Source Code Pro\",style=filled,fillcolor=white]\n")
  f.write("  edge [color=black]\n")
  f.write("  fontname=\"Source Code Pro bold\"\n")
  f.write("  nodesep=1\n")
  f.write("  ranksep=2\n")
  f.write("  ;\n")

  recorder = Callgraph::Recorders::Sqlite.new(ARGV[0])
  method_calls = if options[:subtrees]
    method_calls = recorder.method_calls.to_a

    # Use transitive closure nodes to determine what ids to include
    to_include = method_calls.each_with_object(Set.new) do |mc, to_include|
      next if options[:subtrees] !~ mc.source.receiver_class.to_s
      to_include << mc.source.id
      to_include << mc.target.id
    end

    method_calls.select do |mc|
      to_include.include?(mc.source.id) && to_include.include?(mc.target.id)
    end
  else
    recorder.method_calls.to_a
  end

  method_calls = method_calls.select do |mc|
    next false if mc.transitive && !options[:transitive]

    if options[:include]
      next false if options[:include] !~ mc.source.receiver_class.to_s
      next false if options[:include] !~ mc.target.receiver_class.to_s
    end
    if options[:exclude]
      next false if options[:exclude] =~ mc.source.receiver_class.to_s
      next false if options[:exclude] =~ mc.target.receiver_class.to_s
    end

    true
  end

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
      f.write("    color = gray50;\n")
      f.write("    bgcolor = gray95;\n")
      f.write("    fontcolor = gray50;\n")
      methods.each do |method|
        f.write("    \"#{method}\";\n")
      end
      f.write("  }\n\n")
    end
  end

  # Now the edges
  method_calls.each do |mc|
    f.write("  \"#{mc.source}\" -> \"#{mc.target}\"")
    f.write(" [style=dotted]") if mc.transitive
    f.write(";\n")
  end

  f.write("}\n")
end

`dot -Tpng callgraph.dot > callgraph.png` if options[:preview] || options[:output]
`open callgraph.png` if options[:preview]
