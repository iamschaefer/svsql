require 'spec_helper'
require 'sqlite3'

describe 'CSV Parsing' do
  before do
    @db_file = 'test.sqlite3'
    File.delete(@db_file) if File.exist?(@db_file)
    journal = "#{@db_file}-journal"
    File.delete(journal) if File.exist?(journal)
  end

  it 'should parse all rows' do
    file = 'spec/fixtures/nasa_19950801.csv'
    options = ["\t", file, @db_file]
    Svsql.main(options)

    db = SQLite3::Database.open(@db_file)
    result = db.execute(" select count(*) from 'tsvql'")
    row_count = result[0][0]
    db.close

    expect(row_count).to be 30_969
  end
end
