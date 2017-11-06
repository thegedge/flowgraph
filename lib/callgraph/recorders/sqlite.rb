require 'sqlite3'

module Callgraph
  module Recorders
    class Sqlite < Recorder
      def initialize(db_path)
        @db_path = db_path
      end

      def record(event)
        if event.type == :call
          #puts [event.method_name, event.defined_class, event.receiver].inspect
          database.execute(
            "INSERT OR REPLACE INTO methods
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
          db.execute <<-SQL
            CREATE TABLE IF NOT EXISTS methods (
              name varchar(255),
              class varchar(255),
              path varchar(255),
              line_number integer,
              type varchar(32),

              PRIMARY KEY (name, class, type)
            );

            CREATE INDEX IF NOT EXISTS name ON methods(name);
          SQL
        end
      end
    end
  end
end
