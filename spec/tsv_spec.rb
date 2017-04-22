require 'spec_helper'
require 'sqlite3'

describe 'TSV Parsing' do
  before do
    @db_file = 'test.sqlite3'
    File.delete(@db_file) if File.exist?(@db_file)
    journal = "#{@db_file}-journal"
    File.delete(journal) if File.exist?(journal)
  end

  it 'should parse all rows' do
    file = 'spec/fixtures/nasa_19950801.tsv'
    options = ["\t", file, @db_file]
    Svsql.main(options)

    db = SQLite3::Database.open(@db_file)
    result = db.execute(" select count(*) from 'tsvql'")
    row_count = result[0][0]
    db.close

    expect(row_count).to be 30_969
  end

  # it 'performs' do
  #   batch_sizes = %w(100, 1_000, 10_000, 20_000, 60_000, 100_000).map(&:to_i)
  #   batch_sizes.each do |batch_size|
  #     @db_file = 'test.sqlite3'
  #     File.delete(@db_file) if File.exist?(@db_file)
  #     journal = "#{@db_file}-journal"
  #     File.delete(journal) if File.exist?(journal)
  #
  #     file = 'spec/fixtures/nasa_19950801.tsv'
  #     options = ["\t", file, @db_file]
  #
  #
  #     Svsql::BATCH_SIZE = batch_size
  #
  #     start_time = Time.now
  #     Svsql.main(options)
  #     end_time = Time.now
  #     puts "#{end_time - start_time} for batch size #{batch_size}"
  #   end
  # end
end
