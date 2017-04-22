##
# Provides the various type parsers we have.
class TypeParserFactory
  def self.build(type)
    case type
    when 'string'
      StringTypeParser
    when 'int'
      IntegerTypeParser
    when 'float'
      FloatTypeParser
    else
      raise "No TypeParser found for #{type}"
    end
  end
end
