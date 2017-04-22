# frozen_string_literal: true

#
require 'svsql/version'
require 'sqlite3'

module Svsql
  BATCH_SIZE = 20_000 # experimentally tuned
  DEFAULT_TABLE = 'tsvql'.freeze

  def self.parse_row(line, separator)
    split = line.split(separator)
    result = []
    split.each do |h|
      result << h.strip
    end
    result
  end

  def self.cli_options
    ARGV
  end

  def self.main(args = cli_options)
    separator = delimiter_from_args(args)
    file = target_from_args(args)
    db_file_name = desination_from_args(args)

    f = File.open(file)

    column_names = parse_column_names(f, separator)

    sq_lite_database_new = SQLite3::Database.new db_file_name
    db = sq_lite_database_new

    create_table(column_names, db)

    line_count = insert_rows(db, f, separator)

    puts "Parsed #{file} and created #{db_file_name} with a table of #{line_count} rows"

    f.close
    db.close
    nil
  end

  def self.insert_rows(db, f, separator)
    line_count = 0
    insert_pre = "insert into '#{DEFAULT_TABLE}' VALUES "
    loop do
      values_part = []
      begin
        BATCH_SIZE.times do
          values_part << row_values(f, separator)
          line_count += 1
        end

        insert_command = insert_pre + values_part.join(',')
        try_execute(db, insert_command)
      rescue EOFError
        # We finished parsing. That's ok.
        insert_command = insert_pre + values_part.join(',') unless (line_count % BATCH_SIZE).zero?
        try_execute(db, insert_command)
        break
      end
    end
    line_count
  end

  def self.row_values(f, separator)
    line = f.readline
    row_values = parse_row(line, separator)
    '(' + row_values.map { |s| "'#{s}'" }.join(',') + ')'
  end

  def self.create_table(column_names, db)
    create_table_command_parts = []
    create_table_command_parts << "create table '#{DEFAULT_TABLE}' ("
    column_names.each_with_index do |_type, i|
      create_table_command_parts << ', ' unless i.zero?
      create_table_command_parts << "\n #{column_names[i]} nvarchar(32)"
    end

    create_table_command_parts << ");\n"
    try_execute(db, create_table_command_parts.join)
  end

  def self.parse_column_names(f, separator)
    first_line = f.readline
    parse_row(first_line, separator)
  end

  def self.desination_from_args(args)
    args[2]
  end

  def self.target_from_args(args)
    args[1]
  end

  def self.delimiter_from_args(args)
    args[0]
  end

  def self.try_execute(db, *args)
    db.execute(*args)
  rescue SQLite3::SQLException => e
    puts "Failed executing statement:\n #{args}"
    raise e
  end
end
