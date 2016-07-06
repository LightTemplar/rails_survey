require 'scoring/schemes/scoring_scheme'
require 'scoring/schemes/bank_scheme'
require 'scoring/schemes/sum_scheme'
require 'scoring/schemes/search_scheme'
require 'scoring/schemes/lookup_scheme'
require 'scoring/schemes/indexed_scheme'
require 'scoring/schemes/integer_scheme'
require 'scoring/schemes/group_average_scheme'
require 'scoring/schemes/matching_scheme'
require 'scoring/schemes/manual_scheme'
require 'scoring/schemes/child_roster_scheme'
require 'scoring/schemes/staff_roster_scheme'
require 'scoring/schemes/staff_role_scheme'

class SchemeGenerator

  def self.generate(row)
    scoring_scheme = nil
    if row[6].strip == 'Manual'
      question_identifiers = row[0].strip.split(/\r?\n/)
      if question_identifiers.length > 1 && !row[2].include?('Roster')
        scoring_scheme = []
        question_identifiers.each do |identifier|
          scoring_scheme << ManualScheme.new(identifier.strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
        end
      else
        scoring_scheme = ManualScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      end
    elsif row[6].strip == 'Bank scoring'
      scoring_scheme = BankScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      white_space_index = row[5].index(' ')
      scoring_scheme.exclude_index = row[5][0..white_space_index].split(';')[1]
      scoring_scheme.ref_option_index_raw_score = row[5][white_space_index+1..row[5].length-1]
    elsif row[6].strip == 'Matching'
      scoring_scheme = MatchingScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      parse_question_identifiers(scoring_scheme, row)
    elsif row[6].strip == 'Indexed' && row[2].strip != 'Roster'
      scoring_scheme = IndexedScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      parse_question_identifiers(scoring_scheme, row)
      if row[5].include?('exclude')
        white_space_index = row[5].index(' ')
        scoring_scheme.exclude_index = row[5][0..white_space_index].split(';')[1]
        scoring_scheme.ref_option_index_raw_score = row[5][white_space_index+1..row[5].length-1]
      else
        scoring_scheme.ref_option_index_raw_score = row[5]
      end
      scoring_scheme.relevant_index = row[1] if row[1]
    elsif row[6].strip == 'Simple search' && row[2].strip != 'Roster'
      scoring_scheme = SearchScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      white_space_index = row[5].index(' ')
      scoring_scheme.word_bank = row[5][0..white_space_index]
      scoring_scheme.key_score_mapping = row[5][white_space_index+1..row[5].length-1]
    elsif row[6].strip == 'Lookup'
      scoring_scheme = LookupScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
    elsif row[6].strip == 'Sum'
      scoring_scheme = SumScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      exclude_index = row[5].index('exclude')
      white_space_index = row[5].index(' ')
      if exclude_index && white_space_index
        scoring_scheme.exclude_index = row[5][0..white_space_index].split(';')[1]
        scoring_scheme.key_score_mapping = row[5][white_space_index+1..row[5].length-1]
      else
        scoring_scheme.key_score_mapping = row[5]
      end
    elsif row[6].strip == 'Calculation' && row[2] == 'INTEGER'
      scoring_scheme = IntegerScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      scoring_scheme.key_score_mapping = row[5] unless row[5].blank?
    elsif row[6].strip == 'Group average'
      scoring_scheme = GroupAverageScheme.new(row[9].strip, row[1].to_s, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      scoring_scheme.qids = row[0].strip.split
      scoring_scheme.key_score_mapping = row[5] unless row[5].blank?
    elsif row[2].strip == 'Roster' && row[6].strip == 'Simple search'
      scoring_scheme = SearchScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      white_space_index = row[5].index(' ')
      scoring_scheme.word_bank = row[5][0..white_space_index].strip
      scoring_scheme.key_score_mapping = row[5][white_space_index+1..row[5].length-1]
    elsif row[2].strip == 'Roster' && (row[3].strip == 'School' || row[3].strip == 'Vaccinations' || row[3].strip ==
        'Arrival-Assignment lag time')
      scoring_scheme = ChildRosterScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      scoring_scheme.question_text = row[3].strip
      scoring_scheme.key_score_mapping = row[5] unless row[5].blank?
    elsif row[2].strip == 'Roster' && row[6].strip == 'Calculation'
      scoring_scheme = StaffRosterScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7], row[10].to_i, row[11])
      scoring_scheme.ref_option_index_raw_score = row[5] unless row[5].blank?
      scoring_scheme.question_text = row[3].strip
    elsif row[2].strip.include?('Roster') && row[6].strip == 'Roster Matching'
      qids = row[0].strip.split(/\r?\n/)
      qids = qids.take(qids.size - 1)
      scoring_scheme = StaffRoleScheme.new(qids.join(','), row[2].strip.split(/\r?\n/).join(','), row[6].strip, row[7],
                                           row[10].to_i, row[11])
      scoring_scheme.relevant_index = row[1].to_i
      scoring_scheme.question_text = row[3].strip
    end
    scoring_scheme
  end

  def self.parse_question_identifiers(scheme, row)
    qids = row[0].strip.split
    if qids.size > 1
      scheme.qid = qids[1].strip
      scheme.reference_qid = qids[0].strip
    else
      scheme.qid = qids[0]
    end
  end

end