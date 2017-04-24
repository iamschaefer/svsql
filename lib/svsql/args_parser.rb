##
# Helper for arguments from ARGV style arguments
class ArgsParser
  DELIMITER_INDEX = 1
  TARGET_INDEX = 0
  DESTINATION_INDEX = 2
  HEADER_TYPES_START_INDEX = 3

  def initialize(args)
    @args = args
  end

  def delimiter
    @args[DELIMITER_INDEX]
  end

  def target
    @args[TARGET_INDEX]
  end

  def destination
    @args[DESTINATION_INDEX]
  end

  def header_types
    @args[HEADER_TYPES_START_INDEX..-1]
  end
end
