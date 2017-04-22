# frozen_string_literal: true

require 'svsql/version'
require 'svsql/args_parser'
require 'sqlite3'
##
# Core of the SVSQL module. This is the interface to the outside world.
module Svsql
  BATCH_SIZE = 500 # by default, this is the maximum for SQLite3 compilations. It would be much faster if we increased this though.
  DEFAULT_TABLE = 'tsvql'.freeze

  def self.line_to_array(line, separator)
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

  def self.main(args = cli_options, console_out = $stdout)
    ap = ArgsParser.new(args)

    f = File.open(ap.target)
    line_count = write_db(ap, f)
    f.close
    console_out.puts "Parsed #{ap.target} and created #{ap.destination} with a table of #{line_count} rows"
  end

  def self.write_db(ap, f)
    db = SQLite3::Database.new ap.destination
    column_names = parse_column_names(f, ap.delimiter)
    create_table(column_names, db)
    create_indices(column_names, db)
    line_count = insert_rows(db, f, ap.delimiter)
    db.close
    line_count
  end

  def self.insert_rows(db, f, separator)
    line_count = 0
    insert_pre = "insert into '#{DEFAULT_TABLE}' VALUES "
    loop do
      values_part = batch_sql(f, separator)
      line_count += values_part.size
      insert_command = insert_pre + values_part.join(',')
      try_execute(db, insert_command)
      break if f.eof?
    end
    line_count
  end

  def self.batch_sql(f, separator)
    values_part = []
    BATCH_SIZE.times do
      break if f.eof?
      values_part << row_values(f, separator)
    end
    values_part
  end

  def self.row_values(f, separator)
    line = f.readline
    row_values = line_to_array(line, separator)
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

  ##
  # Create indicies for every column that ends in 'id'
  def self.create_indices(column_names, db)
    column_names.each do |c|
      if c.downcase.end_with? 'id'
        command = "create index #{c}_index on #{DEFAULT_TABLE}(#{c})"
        try_execute(db, command)
      end
    end
  end

  def self.parse_column_names(f, separator)
    first_line = f.readline
    line_to_array(first_line, separator)
  end

  def self.try_execute(db, *args)
    db.execute(*args)
  end
end
