require 'scoring/schemes/scoring_scheme'
require 'scoring/schemes/bank_scheme'
require 'scoring/schemes/sum_scheme'
require 'scoring/schemes/search_scheme'
require 'scoring/schemes/lookup_scheme'
require 'scoring/schemes/indexed_scheme'
require 'scoring/schemes/integer_scheme'
require 'scoring/schemes/group_average_scheme'
require 'scoring/schemes/calculation_scheme'
require 'scoring/schemes/matching_scheme'
require 'scoring/scores/score'
require 'scoring/scores/group_score'
require 'scoring/crib_bed'

# Example run: rake survey:score['/path/to/base/dir/']
namespace :survey do
  task :score, [:path_str] do |task_name, args|
    base_dir = args[:path_str]
    scoring_schemes = []
    group_score_schemes = []
    book = Roo::Spreadsheet.open(base_dir + 'NonObsScoring-ForLeo.xlsx', extension: :xlsx)
    sheet1 = book.sheet('Scoring')

    # === Rosters ===
    # previous_care_terms = []
    # Dir.glob(base_dir + 'Rosters_Phase_II/*.xlsx').each do |filename|
    #   center_id = filename.split('/').last.gsub(/[^\d]/, '')
    #   puts center_id
    #   roster_book = Roo::Spreadsheet.open(filename, extension: :xlsx)
    #   staff_sheet = roster_book.sheet('Personal')
    #   children_sheet = roster_book.sheet('Niños y Niñas')
    #
    #   # child section
    #   children_sheet.drop(3).each do |row|
    #     if !row[1].blank? && !row[10].blank?
    #       row[10].class == Float ? previous_care = row[10].round.to_s : previous_care = row[10]
    #         unless previous_care_terms.include?(previous_care.strip)
    #           previous_care_terms.push(previous_care.strip)
    #         end
    #     end
    #   end
    #
    #   # staff section
    #   staff_sheet.drop(3).each do |row|
    #
    #   end
    # end
    # puts previous_care_terms.inspect
    # next  # TODO Temporary

    # Initialize crib beds
    CribBed.initialize_cribs(base_dir + 'NonObsScoring-ForLeo.xlsx')

    # Generate scoring schemes
    sheet1.drop(1).each do |row|
      scoring_scheme = nil
      if row[6].strip == 'Bank scoring'
        scoring_scheme = BankScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
        white_space_index = row[5].index(' ')
        scoring_scheme.exclude_index = row[5][0..white_space_index].split(';')[1]
        scoring_scheme.ref_option_index_raw_score = row[5][white_space_index+1..row[5].length-1]
      elsif row[6].strip == 'Matching'
        scoring_scheme = MatchingScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
        parse_qids(scoring_scheme, row)
      elsif row[6].strip == 'Indexed' && row[2].strip != 'Roster'
        scoring_scheme = IndexedScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
        parse_qids(scoring_scheme, row)
        if row[5].include?('exclude')
          white_space_index = row[5].index(' ')
          scoring_scheme.exclude_index = row[5][0..white_space_index].split(';')[1]
          scoring_scheme.ref_option_index_raw_score = row[5][white_space_index+1..row[5].length-1]
        else
          scoring_scheme.ref_option_index_raw_score = row[5]
        end
        scoring_scheme.relevant_index = row[1] if row[1]
      elsif row[6].strip == 'Simple search' && row[2].strip != 'Roster'
        scoring_scheme = SearchScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
        white_space_index = row[5].index(' ')
        scoring_scheme.word_bank = row[5][0..white_space_index]
        scoring_scheme.key_score_mapping = row[5][white_space_index+1..row[5].length-1]
      elsif row[6].strip == 'Lookup'
        scoring_scheme = LookupScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
      elsif row[6].strip == 'Sum'
        scoring_scheme = SumScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
        exclude_index = row[5].index('exclude')
        white_space_index = row[5].index(' ')
        if exclude_index && white_space_index
          scoring_scheme.exclude_index = row[5][0..white_space_index].split(';')[1]
          scoring_scheme.key_score_mapping = row[5][white_space_index+1..row[5].length-1]
        else
          scoring_scheme.key_score_mapping = row[5]
        end
      elsif row[6].strip == 'Calculation' && row[2] == 'INTEGER'
        scoring_scheme = IntegerScheme.new(row[0].strip, row[2].strip, row[6].strip, row[7])
        scoring_scheme.key_score_mapping = row[5] unless row[5].blank?
      elsif row[6].strip == 'Group average'
        scoring_scheme = GroupAverageScheme.new(row[9].strip, row[1].to_s, row[2].strip, row[6].strip, row[7])
        scoring_scheme.qids = row[0].strip.split
        scoring_scheme.key_score_mapping = row[5] unless row[5].blank?
        group_score_schemes.push(scoring_scheme)
        # next #TODO What was this for?
      end
      scoring_schemes.push(scoring_scheme) unless scoring_scheme.nil?
    end

    # Parse responses and create score objects
    header = []
    response_scores = []
    scores = []
    Dir.glob(base_dir + 'surveys/*.csv').each do |filename|
      CSV.foreach(filename) do |row|
        if $. == 1
          header = row
        else
          qid = header.index('qid') ? row[header.index('qid')] : nil
          if qid
            survey_id = header.index('survey_id') ? row[header.index('survey_id')] : nil
            survey_uuid = header.index('survey_uuid') ? row[header.index('survey_uuid')] : nil
            device_label = header.index('device_label') ? row[header.index('device_label')] : nil
            device_user = header.index('device_user_username') ? row[header.index('device_user_username')] : nil
            center_id = header.index('Center ID') ? row[header.index('Center ID')] : nil
            instrument_id = header.index('instrument_id') ? row[header.index('instrument_id')] : nil
            question_type = header.index('question_type') ? row[header.index('question_type')] : nil
            response = header.index('response') ? row[header.index('response')] : nil
            response_scores.push(Score.new(qid, survey_id, survey_uuid, device_label, device_user, center_id, instrument_id,
                      question_type, response))
          end
        end
      end
    end

    group_identifiers = group_score_schemes.collect { |item| item.qids }.flatten
    group_response_scores = []

    # Initialize centers
    centers = CalculationScheme.initialize_centers(base_dir + 'NonObsScoring-ForLeo.xlsx')

    # Score individual responses
    response_scores.each do |sc|
      scheme = scoring_schemes.find{|obj| obj.qid == sc.qid && obj.question_type == sc.question_type}
      if scheme #Only score those that have scoring schemes
        if scheme.description == 'Indexed' || scheme.description == 'Matching'
          reference = nil
          if scheme.reference_qid
            reference = response_scores.find{|obj| obj.qid == scheme.reference_qid && obj.center_id == sc.center_id}
            if reference.nil?
              #TODO Why is it nil on some instances
            end
          end
          sc.raw_score = scheme.score(sc, reference)
        else
          sc.raw_score = scheme.score(sc)
        end
        sc.scheme_description = scheme.description
        sc.weight = scheme.assign_weight(sc.center_id)
        scores.push(sc)

        # === beging tests ===
        # if scheme.description == 'Lookup'
        #   puts sc.raw_score
        # end
        # === end tests ===

      elsif group_identifiers.find{|ob| ob == sc.qid}
        group_response_scores.push(sc)
      end
    end

    # Score group responses
    centers.each do |center|
      group_score_schemes.each do |group_scheme|
        center_grs = group_response_scores.find_all{|grs| grs.center_id == center.id}
        score_group = GroupScore.new(group_scheme.name, group_scheme.qids, center.id,
                                     center_grs.try(:first).try(:instrument_id),
                                     center_grs.try(:first).try(:question_type))
        score_group.raw_score = group_scheme.score(center_grs, centers)
        score_group.scheme_description = group_scheme.name
        score_group.weight = group_scheme.assign_weight
        scores.push(score_group)
      end
    end

    puts scores.size

    # Export scores to csv file
    csv_file = base_dir + 'scores.csv'
    CSV.open(csv_file, 'wb') do |csv|
      header = %w[center_id instrument_id survey_id survey_uuid device_label device_user qid question_type
                scoring_description response weight raw_score weighted_score]
      csv << header
      scores.each do |score|
        row = [score.center_id, score.instrument_id, score.survey_id, score.survey_uuid, score.device_label,
               score.device_user, score.qid, score.question_type, score.scheme_description, score.response,
               score.weight, score.raw_score, score.weighted_score]
        csv << row
        # puts row.inspect
      end
    end

  end

  def parse_qids(score, row)
    qids = row[0].strip.split
    if qids.size > 1
      score.qid = qids[1].strip
      score.reference_qid = qids[0].strip
    else
      score.qid = qids[0]
    end
  end

end