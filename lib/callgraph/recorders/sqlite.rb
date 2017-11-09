require 'sqlite3'

module Callgraph
  module Recorders
    class Sqlite < Recorder
      def initialize(db_path)
        @db_path = db_path
      end

      def record(event)
        if event.type == :call
          database.execute(
            "INSERT OR IGNORE INTO methods
              (name, class, path, line_number, type)
              VALUES(?, ?, ?, ?, ?)
            ",
            event.method_name.to_s,
            event.defined_class_name,
            event.defined_path,
            event.defined_line_number,
            event.method_type.to_s
          )
        end
      end

      private

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
          ")
        end
      end
    end
  end
end
