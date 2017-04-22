##
# Helper for arguments from ARGV style arguments
class ArgsParser
  def initialize(args)
    @args = args
  end

  def delimiter
    @args[1]
  end

  def target
    @args[0]
  end

  def destination
    @args[2]
  end
end
