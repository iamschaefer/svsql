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
    separator = args[0]
    file = args[1]
    db_file_name = args[2]
    header_types = []
    header_types_start = 3
    h_i = header_types_start
    loop do
      arg = args[h_i]
      break if arg.nil?
      header_types << arg
    end

    f = File.open(file)
    first_line = f.readline

    column_names = parse_row(first_line, separator)

    db = SQLite3::Database.new db_file_name

    create_table_command_parts = []
    create_table_command_parts << "create table '#{DEFAULT_TABLE}' ("
    column_names.each_with_index do |_type, i|
      create_table_command_parts << ', ' unless i.zero?
      create_table_command_parts << "\n #{column_names[i]} nvarchar(32)"
    end

    create_table_command_parts << ");\n"
    db.execute create_table_command_parts.join

    line_count = 0
    cs_column_names = column_names.map { |s| "'#{s}'" }.join(', ')
    insert_pre = "insert into '#{DEFAULT_TABLE}' (#{cs_column_names}) VALUES "
    loop do
      values_part = []
      begin
        BATCH_SIZE.times do
          line = f.readline
          row_values = parse_row(line, separator)
          values = '(' + row_values.map { |s| "'#{s}'" }.join(',') + ')'
          values_part << values
          line_count += 1
        end

        insert_command = insert_pre + values_part.join(',')
        db.execute(insert_command)
      rescue EOFError
        # We finished parsing. That's ok.
        insert_command = insert_pre + values_part.join(',') unless (line_count % BATCH_SIZE).zero?
        db.execute(insert_command)
        break
      end
    end

    puts "Parsed #{file} and created #{db_file_name} with a table of #{line_count} rows"

    f.close
    db.close
    nil
  end
end
