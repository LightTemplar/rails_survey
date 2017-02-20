# Initializes scoring schemes
class SchemeGenerator
  def self.generate(unit)
    case unit.score_type
    when 'single_select'
      Match.new
    when 'multiple_select'
      Bank.new
    when 'multiple_select_sum'
      Sum.new
    when 'range'
      Span.new
    when 'simple_search'
      Search.new
    end
  end
end
