desc 'Import from CSV file'
task :v1_v2_import, [:filename] => :environment do |_t, args|
  CSV.foreach(args[:filename], headers: true) do |row|
    if !row[0].blank?
      if row[2].strip != 'INSTRUCTIONS'
        question_set = QuestionSet.find_by_title(row[0].strip)
        if question_set.nil?
          question_set = QuestionSet.create!(title: row[0].strip)
        end
      end
      if row[2].strip == 'INSTRUCTIONS'
        instruction = Instruction.find_by_text(row[5].strip)
        if instruction.nil?
          instruction = Instruction.create!(title: row[1].strip, text: row[5].strip)
          instruction_translation = InstructionTranslation.create!(
            instruction_id: instruction.id, language: 'es', text: row[6].strip
          )
        end
      else
        question = Question.find_by_question_identifier(row[1].strip)
        if question.nil?
          question_set = QuestionSet.find_by_title(row[0].strip)
          question = Question.create!(
            question_identifier: row[1].strip,
            question_set_id: question_set.id,
            question_type: row[2].strip,
            text: row[5].strip
          )
          QuestionTranslation.create!(
            question_id: question.id,
            language: 'es',
            text: row[6].strip
          )
        end
      end
    end
    if !row[4].blank?
      option_set = OptionSet.find_by_title(row[4].strip)
      if option_set.nil?
        option_set = OptionSet.create!(title: row[4].strip)
      end
      question = Question.find_by_question_identifier(row[1].strip)
      if question && question.option_set_id != option_set.id
        question.option_set_id = option_set.id
        question.save!
      end
      option = Option.find_by_identifier(row[5].strip)
      if option.nil?
        option = Option.create!(text: row[5].strip, identifier: row[5].strip)
        option_translation = option.translations.where(
          language: 'es', text: row[6].strip
        ).first
        if option_translation.nil?
          option_translation = OptionTranslation.create!(
            option_id: option.id, language: 'es', text: row[6].strip
          )
        end
      end
      option_set.reload
      option_in_option_set = option_set.option_in_option_sets.where(option_id: option.id).first
      if option_in_option_set.nil?
        OptionInOptionSet.create!(
          option_id: option.id,
          number_in_question: option_set.option_in_option_sets.size,
          option_set_id: option_set.id
        )
      end
    end
  end
end
