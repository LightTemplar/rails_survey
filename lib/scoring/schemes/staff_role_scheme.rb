class StaffRoleScheme < ScoringScheme
  attr :question_text

  def question_text=(text)
    @question_text = text
  end

  def match_roles(staff_sheet, center_id, role_column, role_responses)
    roster_roles = []
    response_roles = []
    parsed_roles = []
    # puts center_id
    staff_sheet.drop(3).each do |row|
      if !row[1].blank? && is_correct_id(row[1]) && !row[role_column].blank?
        if row[role_column].include?('/')
          roster_roles.concat(row[role_column].split('/').map(&:downcase))
        else
          roster_roles.push(row[role_column].strip.downcase)
        end
        role_responses.each do |response|
          response_roles.push(response.response.split(',')[relevant_index].try(:downcase)) unless response.response.blank?
        end
      end
    end
    roster_roles.each do |role|
      response_roles.each do |resp_role|
        if resp_role && resp_role.include?(role)
          parsed_roles.push(role)
        else
          if resp_role && resp_role.include?('/')
            parsed_roles.concat(resp_role.split('/').map(&:downcase))
          elsif resp_role && resp_role.include?(' y ')
            parsed_roles.concat(resp_role.split(' y ').map(&:downcase))
          else
            parsed_roles.push(resp_role)
          end
        end
      end
    end
    roster_roles = roster_roles.map(&:strip)
    roster_roles = roster_roles.uniq
    parsed_roles = parsed_roles.compact
    parsed_roles = parsed_roles.map(&:strip)
    parsed_roles = parsed_roles.map{|role| I18n.transliterate(role)}
    parsed_roles = parsed_roles.uniq

    first_index = parsed_roles.index('cocineras')
    second_index = parsed_roles.index('cocinera')
    third_index = parsed_roles.index('cosinera')
    fourth_index = parsed_roles.index('cosineras')
    fifth_index = parsed_roles.index('educadoras')

    parsed_roles[first_index] = 'cocina' if first_index
    parsed_roles[second_index] = 'cocina' if second_index
    parsed_roles[third_index] = 'cocina' if third_index
    parsed_roles[fourth_index] = 'cocina' if fourth_index
    parsed_roles[fifth_index] = 'educadora' if fifth_index

    role_union = roster_roles & parsed_roles

    if parsed_roles.size < 2
      raw_score = 1
    elsif role_union.size == parsed_roles.size
      raw_score = 7
    elsif role_union.size == 0
      raw_score = 1
    else
      #TODO Inspect
      # puts roster_roles.inspect
      # puts parsed_roles.inspect
      raw_score = 4
    end
    roster_score = RosterScore.new(qid, question_type, center_id, description)
    roster_score.raw_score = raw_score
    roster_score.weight = assign_weight(center_id)
    roster_score.domain = domain
    roster_score.sub_domain = sub_domain
    roster_score
  end

end