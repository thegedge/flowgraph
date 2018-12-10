# frozen_string_literal: true
require "sqlite3"

module Flowgraph
  module Recorders
    class Sqlite < Recorder
      METHODS_TABLE = "methods"
      METHOD_CALLS_TABLE = "method_calls"

      _Method = Struct.new("Method", :id, :name, :receiver_class, :defined_class, :path, :line_number, :type)
      class Method < _Method
        def initialize(id, name, receiver_class, defined_class, path, line_number, type)
          super(id.to_i, name, receiver_class, defined_class, path, line_number.to_i, type.to_sym)
        end

        def prefix
          case type
          when :module, :class
            "."
          else
            "#"
          end
        end

        def to_s
          case type
          when :singleton
            "#{defined_class}#{prefix}#{name} (singleton)"
          when :module, :class
            "#{defined_class}#{prefix}#{name}"
          end
        end
      end

      MethodCall = Struct.new("MethodCall", :source, :target, :transitive)

      def initialize(db_path)
        @db_path = db_path
        @stack = Stack.new("sqlite")
      end

      def record(event)
        if event.type == :return
          @stack.pop
          return
        end

        @stack << store_event(event)
        return unless @stack.length > 1

        # Insert the direct call
        database.execute(
          "INSERT OR REPLACE INTO #{METHOD_CALLS_TABLE}(source_id, target_id, transitive) VALUES(?, ?, ?)",
          [
            @stack[-2],
            @stack[-1],
            0
          ],
        )

        # Insert the transitive calls
        if @stack.length > 2
          values = @stack.reverse.drop(1).map { |source| "(#{source},#{@stack.last},1)" }
          database.execute(
            "INSERT OR IGNORE INTO #{METHOD_CALLS_TABLE}(source_id, target_id, transitive) VALUES #{values.join(",")}"
          )
        end
      end

      def database
        @database ||= SQLite3::Database.new(@db_path).tap do |db|
          db.locking_mode = 'exclusive'
          db.temp_store = 'memory'
          db.journal_mode = 'persist'
          db.synchronous = 'off'

          db.execute_batch(
            "CREATE TABLE IF NOT EXISTS #{METHODS_TABLE} (
              id integer PRIMARY KEY AUTOINCREMENT,
              name varchar(255),
              receiver_class varchar(255),
              defined_class varchar(255),
              path varchar(255),
              line_number integer,
              type varchar(32)
            );

            CREATE UNIQUE INDEX IF NOT EXISTS unique_method
              ON #{METHODS_TABLE}(name, receiver_class, defined_class, path, line_number, type);

            CREATE INDEX IF NOT EXISTS name ON #{METHODS_TABLE}(name);

            CREATE TABLE IF NOT EXISTS #{METHOD_CALLS_TABLE} (
              source_id integer,
              target_id integer,
              transitive boolean,

              PRIMARY KEY(source_id, target_id),
              FOREIGN KEY(source_id) REFERENCES #{METHODS_TABLE}(id),
              FOREIGN KEY(target_id) REFERENCES #{METHODS_TABLE}(id)
            );"
          )
        end
      end

      def methods
        rows = database.execute("SELECT #{Method.members.join(", ")} FROM #{METHODS_TABLE}")
        rows.each_with_object({}) do |members, h|
          h[members.first] = Method.new(*members)
        end
      end

      def method_calls
        return enum_for(:method_calls) unless block_given?

        method_instances = methods

        query = "SELECT transitive, source_id, target_id FROM #{METHOD_CALLS_TABLE}"
        database.execute(query).each do |transitive, source_id, target_id|
          yield MethodCall.new(
            source_id == -1 ? nil : method_instances[source_id],
            method_instances[target_id],
            transitive != 0,
          )
        end
      end

      private

      def store_event(event)
        database.execute(
          "INSERT INTO #{METHODS_TABLE}(name, receiver_class, defined_class, path, line_number, type)" \
          "  VALUES(?, ?, ?, ?, ?, ?)",
          [
            event.method_name.to_s,
            event.receiver_class_name,
            event.defined_class_name,
            event.defined_path,
            event.defined_line_number,
            event.method_type.to_s,
          ]
        )
        database.last_insert_row_id
      rescue SQLite3::ConstraintException => e
        database.get_first_value(
          "SELECT id" \
          "  FROM #{METHODS_TABLE}" \
          "  WHERE name=? AND receiver_class=? AND defined_class=? AND path=? AND line_number=? AND type=?",
          [
            event.method_name.to_s,
            event.receiver_class_name,
            event.defined_class_name,
            event.defined_path,
            event.defined_line_number,
            event.method_type.to_s,
          ]
        )
      end
    end
  end
end
