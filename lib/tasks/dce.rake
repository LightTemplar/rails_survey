# frozen_string_literal: true

require 'dce/project_setup'

# Run using the command `rake 'dce[:project_id]'`
desc 'Create DCE tasks from CSV files'
task :dce, [:project_id] => :environment do |_t, args|
  ps = ProjectSetup.new(args[:project_id])
  ps.setup_instrument
  instrument = ps.instrument
  ps.translation_language
  puts instrument.inspect
  ps.setup_demographics
  languages = %w[sw km]

  ps.files.each do |filename|
    puts "name = #{filename}"
    CSV.foreach(filename, headers: true) do |row|
      break if row[0].blank?

      ps.setup_qs(filename, row)
      prefix = ps.prefix
      folder = ps.folder
      ps.setup_section
      section = ps.section
      puts section.inspect
      ps.setup_display
      display = ps.display
      puts display.inspect

      first_text = I18n.t('dce.first_text', locale: 'en')
      second_text = I18n.t('dce.second_text', locale: 'en')
      ins_one = Instruction.find_or_create_by(title: first_text)
      ins_one.update(text: first_text)
      ins_two = Instruction.find_or_create_by(title: second_text)
      ins_two.update(text: second_text)

      languages.each do |lang|
        first_text_tr = I18n.t('dce.first_text', locale: lang)
        ins_one.instruction_translations.find_or_create_by(language: lang)
               .update(text: first_text_tr)
        second_text_tr = I18n.t('dce.second_text', locale: lang)
        ins_two.instruction_translations.find_or_create_by(language: lang)
               .update(text: second_text_tr)
      end

      folder.reload
      option_set = OptionSet.find_or_create_by(title: "#{row[3]}-#{prefix}#{row[4]}")
      option_set.update(instruction_id: ins_two.id)
      question = folder.questions.find_or_create_by(question_identifier: "#{row[3]}-#{prefix}#{row[4]}")
      question.update(text: I18n.t('dce.third_text', locale: 'en'),
                      question_type: 'CHOICE_TASK',
                      question_set_id: folder.question_set_id,
                      after_text_instruction_id: ins_one.id,
                      option_set_id: option_set.id,
                      position: folder.questions.size + 1)
      languages.each do |lang|
        third_text_tr = I18n.t('dce.third_text', locale: lang)
        question.translations.find_or_create_by(language: lang)
                .update(text: third_text_tr)
      end
      iq = display.instrument_questions.find_or_create_by(identifier: "#{row[3]}-#{prefix}#{row[4]}")
      display.reload
      instrument.reload
      iq.update(instrument_id: instrument.id,
                question_id: question.id,
                position: display.instrument_questions.size,
                number_in_instrument: instrument.instrument_questions.size)
      ps.setup_gender_skips(iq)

      option_set.option_in_option_sets.each do |oios|
        oc = oios.option_collages
        oc.each(&:destroy) if oc.size > 3
      end

      %w[A B C].each do |letter|
        option = Option.find_or_create_by(identifier: "#{row[3]}-#{prefix}#{row[4]}-#{letter}")
        option.text = "Option #{letter}"
        option.save
        languages.each do |lang|
          fourth_text_tr = I18n.t('dce.fourth_text', locale: lang)
          option.translations.find_or_create_by(language: lang)
                .update(text: "#{fourth_text_tr} #{letter}")
        end
        option_set.reload
        oios = option_set.option_in_option_sets.find_or_create_by(option_id: option.id)
        oios.number_in_question = option_set.option_in_option_sets.size + 1
        oios.save
        cells = { 'A' => [8, 9, 10, 11, 12, 13],
                  'B' => [14, 15, 16, 17, 18, 19],
                  'C' => [20, 21, 22, 23, 24, 25] }
        index = 0
        cells[letter].each_slice(2) do |t_cell, i_cell|
          collage = Collage.find_or_create_by(name: "#{row[t_cell]}-#{row[i_cell]}")
          oios.option_collages.find_or_create_by(collage_id: collage.id).update(position: index)
          t_option = Option.find_or_create_by(identifier: row[t_cell])
          t_option.update(text: row[t_cell])
          collage.diagrams.find_or_create_by(option_id: t_option.id).update(position: 0)
          i_option = Option.find_or_create_by(identifier: row[i_cell])
          i_option.update(text: row[i_cell])
          collage.diagrams.find_or_create_by(option_id: i_option.id).update(position: 1)
          index += 1
        end
      end
      section.reload
      instrument.reload
      fol_dis = section.displays.find_or_create_by(title: "#{prefix}#{row[4]}-#{row[6]}-Followup")
      fol_dis.update(instrument_id: instrument.id,
                     position: section.displays.size + 1,
                     instrument_position: instrument.displays.size + 1)

      puts fol_dis.inspect
      txt = I18n.t('dce.fifth_text', locale: 'en')
      instruction = Instruction.find_or_create_by(title: txt)
      instruction.update(text: txt)
      languages.each do |lang|
        fifth_text_tr = I18n.t('dce.fifth_text', locale: lang)
        instruction.instruction_translations.find_or_create_by(language: lang)
                   .update(text: fifth_text_tr)
      end
      os = OptionSet.find_or_create_by(title: 'Best Option Preference')
      languages.each do |lang|
        translations = [I18n.t('dce.sixth_text', locale: lang),
                        I18n.t('dce.seventh_text', locale: lang),
                        I18n.t('dce.eighth_text', locale: lang)]
        [I18n.t('dce.sixth_text', locale: 'en'),
         I18n.t('dce.seventh_text', locale: 'en'),
         I18n.t('dce.eighth_text', locale: 'en')].each_with_index do |text, index|
          opt = Option.find_or_create_by(identifier: text)
          opt.update(text: text)
          opt.translations.find_or_create_by(language: lang).update(text: translations[index])
          os.option_in_option_sets.find_or_create_by(option_id: opt.id)
            .update(number_in_question: index + 1)
        end
      end

      folder.reload
      fol_qst = folder.questions.find_or_create_by(question_identifier: "#{row[3]}-#{prefix}#{row[4]}-Followup")
      fol_qst.update(text: "<p>#{I18n.t('dce.ninth_text', locale: 'en')}</p>",
                     question_type: 'SELECT_ONE',
                     option_set_id: os.id,
                     question_set_id: folder.question_set_id,
                     after_text_instruction_id: instruction.id,
                     position: folder.questions.size + 1)
      languages.each do |lang|
        fol_qst.translations.find_or_create_by(language: lang)
               .update(text: "<p>#{I18n.t('dce.ninth_text', locale: lang)}</p>")
      end
      fd_iq = fol_dis.instrument_questions.find_or_create_by(identifier: "#{row[3]}-#{prefix}#{row[4]}-Followup")
      fol_dis.reload
      instrument.reload
      fd_iq.update(instrument_id: instrument.id,
                   question_id: fol_qst.id,
                   position: fol_dis.instrument_questions.size,
                   number_in_instrument: instrument.instrument_questions.size,
                   carry_forward_identifier: iq.identifier)
      ps.setup_gender_skips(fd_iq)
    end
  end
  ps.setup_other_skips
end
