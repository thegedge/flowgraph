# frozen_string_literal: true

require "sqlite3"

module Callgraph
  module Recorders
    class Sqlite < Recorder
      def initialize(db_path)
        @db_path = db_path
        @stack = []
      end

      def record(event)
        return unless event.type == :call

        @stack << store_event(event)
        return unless event.parent

        database.execute(
          "INSERT OR IGNORE INTO method_calls(source, target) VALUES(?, ?)",
          @stack[-2],
          @stack[-1]
        )
      end

      private

      def store_event(event)
        database.execute(
          "INSERT INTO methods(name, class, path, line_number, type) VALUES(?, ?, ?, ?, ?)",
          event.method_name.to_s,
          event.defined_class_name,
          event.defined_path,
          event.defined_line_number,
          event.method_type.to_s
        )
        database.last_insert_row_id
      rescue SQLite3::ConstraintException
        database.execute(
          "SELECT id FROM methods WHERE name=? AND class=? AND path=? AND line_number=? AND type=?",
          event.method_name.to_s,
          event.defined_class_name,
          event.defined_path,
          event.defined_line_number,
          event.method_type.to_s
        ).first
      end

      def database
        @database ||= SQLite3::Database.new(@db_path).tap do |db|
          db.execute_batch("
            CREATE TABLE IF NOT EXISTS methods (
              id integer PRIMARY KEY AUTOINCREMENT,
              name varchar(255),
              class varchar(255),
              path varchar(255),
              line_number integer,
              type varchar(32)
            );

            CREATE UNIQUE INDEX IF NOT EXISTS unique_method ON methods(name, class, path, line_number, type);
            CREATE INDEX IF NOT EXISTS name ON methods(name);

            CREATE TABLE IF NOT EXISTS method_calls (
              source integer,
              target integer,

              PRIMARY KEY(source, target),
              FOREIGN KEY(source) REFERENCES methods(id),
              FOREIGN KEY(target) REFERENCES methods(id)
            );
          ")
        end
      end
    end
  end
end
