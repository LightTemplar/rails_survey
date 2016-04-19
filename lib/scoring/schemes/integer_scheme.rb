require 'scoring/schemes/calculation_scheme'

class IntegerScheme < CalculationScheme
  def score(obj)
    return nil if obj.response.blank? || key_score_mapping.blank?
    if obj.response.to_f < 0.5
      key_score_mapping['0...0.5']
    elsif obj.response.to_f > 2
      key_score_mapping['2+']
    else
      key_score_mapping[obj.response.to_s]
    end
  end
end