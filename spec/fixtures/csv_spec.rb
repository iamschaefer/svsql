require 'spec_helper'
require 'sqlite3'

describe 'CSV file' do
  before do
    db_file = 'test.sqlite3'
    File.delete(db_file) if File.exist?(db_file)
    journal = "#{db_file}-journal"
    File.delete(journal) if File.exist?(journal)

    file = 'spec/fixtures/nasa_19950801.csv'
    options = [file, ',', db_file,
               'int', 'text', 'text', 'datetime', 'nvarchar(32)', 'text', 'int', 'int', 'text', 'text']
    # so we don't get puts in the test results
    null_out = File.open(File::NULL, 'w')
    Svsql.main(options, null_out)

    @db = SQLite3::Database.open(db_file)
  end

  after do
    @db.close
  end

  it 'has all rows' do
    result = @db.execute(" select count(*) from 'tsvql'")
    row_count = result[0][0]
    expect(row_count).to be 30_969
  end

  it 'has index for *Id column' do
    result = @db.index_list('tsvql')
    indices = result.map { |r| r[1] }
    expect(indices).to include('requestId_index')
  end
  it 'has correct column names' do
    result = @db.table_info('tsvql')
    table_names = result.map { |r| r['name'] }
    expect(table_names).to match_array %w[requestId host logname time method url response bytes referer useragent]
  end
  it 'has correct column types' do
    result = @db.table_info('tsvql')
    table_names = result.map { |r| r['type'] }
    expected_types = ['int', 'text', 'text', 'datetime', 'nvarchar(32)', 'text', 'int', 'int', 'text', 'text']
    expect(table_names).to match_array expected_types
  end
  pending 'reasonable default column types'
end
