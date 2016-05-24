require 'scoring/crib_bed'

class LookupScheme < ScoringScheme

  MANUAL_LOOKUP = 'manual'

  def score(obj)
    return nil if obj.response.blank?
    scores = []
    obj.response.split(',').each_with_index { |res, index|
      if is_number(res)
        crib_score = CribBed.get_crib_beds.find{|crib| crib.age_index == index && crib.hours_in_bed == res.to_f}
        scores.push(crib_score.raw_score) if crib_score
      else
        num_of_hours = parse_response(res)
        if num_of_hours.class == String
          scores.push(num_of_hours)
        else
          crib_score = CribBed.get_crib_beds.find{|crib| crib.age_index == index && crib.hours_in_bed == num_of_hours}
          scores.push(crib_score.raw_score) if crib_score
        end
      end
    }
    if scores.size > 0 && !scores.include?(MANUAL_LOOKUP)
      scores = scores.compact
      (scores.reduce(:+) / scores.size).round(2)
    else
      MANUAL_LOOKUP
    end
  end

  def parse_response(str)
    return nil if str.blank?
    if str.include?('hora') && str.include?('min')
      str = str.gsub('con', '')
      hours_and_minutes = str.split('hora')
      minutes = hours_and_minutes[1].to_i
      hours = hours_and_minutes[0].to_i
      (hours + minutes/60.0).round
    elsif str.include?('hora')
      hours_arr = str.split('hora')
      hours = hours_arr[0].to_i
      if hours_arr[0].include?('dos')
        hours = 2
      elsif hours_arr[0].include?('una')
        hours = 1
      elsif str.include?('hora y media')
        hours = 1.5
      end
      hours.round
    elsif str.include?('min')
      minutes = str.split('min')
      (minutes[0].to_i / 60.0).round
    else
      # TODO No automatic conversion
      MANUAL_LOOKUP
    end
  end

end