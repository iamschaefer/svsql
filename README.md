# svSQL

[![Build Status](https://secure.travis-ci.org/iamschaefer/svsql.svg)](http://travis-ci.org/iamschaefer/svsql?branch=master)
[![Code Climate](https://codeclimate.com/github/iamschaefer/svsql.svg)](https://codeclimate.com/github/iamschaefer/svsql)


svSQL is a tool for converting CSVs, TSVs, |SVs, and other tabulated data to SQL for easier analysis and importing. The project was motivated by my need to analyze multiple large dumps of TSV and CSV data quickly, but svSQL is also very useful for importing data into your application's database.

svSQL is currently in the alpha stage, so you should expect breaking changes often.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'svsql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install svsql

## Usage

Usage is changing very quickly, so this won't be documented for a while. Your best bet is to check the specs for examples.

## Dependencies

Requires SQLite3 3.7.11 or higher
