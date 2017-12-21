# frozen_string_literal: true

require "sqlite3"

module Callgraph
  module Recorders
    class Sqlite < Recorder
      METHODS_TABLE = "methods"
      METHOD_CALLS_TABLE = "method_calls"

      Method = Struct.new("Method", :name, :class, :path, :line_number, :type)
      MethodCall = Struct.new("MethodCall", :source, :target)

      def initialize(db_path)
        @db_path = db_path
        @stack = []
      end

      def record(event)
        if event.type == :return
          @stack.pop
          return
        end

        @stack << store_event(event)
        return if @stack.length <= 1

        database.execute(
          "INSERT OR IGNORE INTO #{METHOD_CALLS_TABLE}(source, target) VALUES(?, ?)",
          [
            @stack[-2],
            @stack[-1],
          ]
        )
      end

      def database
        @database ||= SQLite3::Database.new(@db_path).tap do |db|
          db.execute_batch("
            CREATE TABLE IF NOT EXISTS #{METHODS_TABLE} (
              id integer PRIMARY KEY AUTOINCREMENT,
              name varchar(255),
              class varchar(255),
              path varchar(255),
              line_number integer,
              type varchar(32)
            );

            CREATE UNIQUE INDEX IF NOT EXISTS unique_method ON #{METHODS_TABLE}(name, class, path, line_number, type);
            CREATE INDEX IF NOT EXISTS name ON #{METHODS_TABLE}(name);

            CREATE TABLE IF NOT EXISTS #{METHOD_CALLS_TABLE} (
              source integer,
              target integer,

              PRIMARY KEY(source, target),
              FOREIGN KEY(source) REFERENCES #{METHODS_TABLE}(id),
              FOREIGN KEY(target) REFERENCES #{METHODS_TABLE}(id)
            );
          ")
        end
      end

      def methods
        rows = database.execute("SELECT id, name, class, path, line_number, type FROM #{METHODS_TABLE}")
        rows.each_with_object({}) do |(id, name, clazz, path, line_number, type), h|
          h[id] = Method.new(name, clazz, path, line_number.to_i, type.to_sym)
        end
      end

      def method_calls
        return enum_for(:method_calls) unless block_given?

        method_instances = methods
        database.execute("SELECT source, target FROM #{METHOD_CALLS_TABLE}").each do |source, target|
          yield MethodCall.new(method_instances[source], method_instances[target])
        end
      end

      private

      def store_event(event)
        database.execute(
          "INSERT INTO #{METHODS_TABLE}(name, class, path, line_number, type) VALUES(?, ?, ?, ?, ?)",
          [
            event.method_name.to_s,
            event.defined_class_name,
            event.defined_path,
            event.defined_line_number,
            event.method_type.to_s,
          ]
        )
        database.last_insert_row_id
      rescue SQLite3::ConstraintException
        database.get_first_value(
          "SELECT id FROM #{METHODS_TABLE} WHERE name=? AND class=? AND path=? AND line_number=? AND type=?",
          [
            event.method_name.to_s,
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
