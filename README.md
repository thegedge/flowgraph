# flowgraph

Simplifies recording and analyzing a call graph from your Ruby code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flowgraph', github: 'thegedge/flowgraph'
```

And then execute:

    $ bundle

## Usage

Generate a SQLite database containing a call graph for your Ruby code:

```ruby
recorder = Flowgraph::Recorders::Sqlite.new("foo.sqlite3")
Flowgraph.trace(recorder) do
  # code to trace goes here
end
```

Or filter out code that doesn't exist inside your project root:

```ruby
recorder = Flowgraph::Recorders::Filtered.only(sqlite_recorder, File.join(__dir__, ".."))
```

To simplify recording in tests, hooks are provided for popular test frameworks:

```ruby
# For RSpec, `in spec/spec_helper.rb`:
Flowgraph::Hooks::RSpec.install_hook(recorder)

# ...or for Minitest, in `test/test_helper.rb`
Flowgraph::Hooks::Minitest.install_hook(recorder)
```

See the [`examples`](https://github.com/thegedge/flowgraph/tree/master/examples) directory for examples of
how to use this gem.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
