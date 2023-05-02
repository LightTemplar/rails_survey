# frozen_string_literal: true

require 'dce/project_setup'

# Run using the command `rake 'dce[:project_id]'`
desc 'Create DCE tasks from CSV files'
task :dce, [:project_id] => :environment do |_t, args|
  ps = ProjectSetup.new(args[:project_id])
  ps.setup_instrument
  instrument = ps.instrument
  language = ps.translation_language
  puts instrument.inspect
  ps.setup_demographics

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

      first_text = 'If these options were available to you right now, which option would you prefer: A, B or C?'
      first_text_sw = 'Kama chaguo hizi zingepatikana kwako sasa, bila gharama, ni chaguo gani ungependelea: A, B au C?'
      second_text = 'Of the two remaining options, which option would you prefer?'
      second_text_sw = 'Kwa chaguo mbili zilizobaki, ni gani ungependelea?'
      ins_one = Instruction.find_or_create_by(title: first_text)
      ins_one.update(text: first_text)
      ins_one.instruction_translations.find_or_create_by(language: language).update(text: first_text_sw)
      ins_two = Instruction.find_or_create_by(title: second_text)
      ins_two.update(text: second_text)
      ins_two.instruction_translations.find_or_create_by(language: language).update(text: second_text_sw)

      folder.reload
      option_set = OptionSet.find_or_create_by(title: "#{row[3]}-#{prefix}#{row[4]}")
      option_set.update(instruction_id: ins_two.id)
      question = folder.questions.find_or_create_by(question_identifier: "#{row[3]}-#{prefix}#{row[4]}")
      question.update(text: 'Please consider the following three options.',
                      question_type: 'CHOICE_TASK',
                      question_set_id: folder.question_set_id,
                      after_text_instruction_id: ins_one.id,
                      option_set_id: option_set.id,
                      position: folder.questions.size + 1)
      question.translations.find_or_create_by(language: language)
              .update(text: 'Tafadhali zingatia chaguo tatu zifuatazo.')

      iq = display.instrument_questions.find_or_create_by(identifier: "#{row[3]}-#{prefix}#{row[4]}")
      display.reload
      instrument.reload
      iq.update(instrument_id: instrument.id,
                question_id: question.id,
                position: display.instrument_questions.size,
                number_in_instrument: instrument.instrument_questions.size)
      ps.setup_gender_skips(iq)

      %w[A B C].each do |letter|
        Option.find_or_create_by(identifier: "#{row[3]}-#{prefix}#{row[4]}-#{letter}") do |option|
          option.text = "Option #{letter}"
          option.save
          option.translations.find_or_create_by(language: language).update(text: "Chaguo #{letter}")
          option_set.reload
          option_set.option_in_option_sets.find_or_create_by(option_id: option.id) do |oios|
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
        end
      end
      section.reload
      instrument.reload
      fol_dis = section.displays.find_or_create_by(title: "#{prefix}#{row[4]}-#{row[6]}-Followup")
      fol_dis.update(instrument_id: instrument.id,
                     position: section.displays.size + 1,
                     instrument_position: instrument.displays.size + 1)

      puts fol_dis.inspect
      txt = 'If you could start using this option today, right now, or continue to do what you normally do, what would you prefer?'
      txt_sw = 'Kama ungeweza kuanza kutumia chaguo hili leo, sasa hivi, ama kuendelea kufanya kile unachofanya kwa kawaida, ungependelea kipi?'
      instruction = Instruction.find_or_create_by(title: txt)
      instruction.update(text: txt)
      instruction.instruction_translations.find_or_create_by(language: language).update(text: txt_sw)
      os = OptionSet.find_or_create_by(title: 'Best Option Preference')
      sw_translations = ['Anza kutumia chaguo hili leo',
                         'Endelea kufanya kile unacho kifanya kwa kawaida',
                         'Sina uhakika']
      ['Start using this option today',
       'Continue to do what you normally do',
       'Not sure'].each_with_index do |text, index|
        opt = Option.find_or_create_by(identifier: text)
        opt.update(text: text)
        opt.translations.find_or_create_by(language: language).update(text: sw_translations[index])
        os.option_in_option_sets.find_or_create_by(option_id: opt.id)
          .update(number_in_question: index + 1)
      end

      folder.reload
      fol_qst = folder.questions.find_or_create_by(question_identifier: "#{row[3]}-#{prefix}#{row[4]}-Followup")
      fol_qst.update(text: '<p>You selected [followup] as your most preferred option.</p>',
                     question_type: 'SELECT_ONE',
                     option_set_id: os.id,
                     question_set_id: folder.question_set_id,
                     after_text_instruction_id: instruction.id,
                     position: folder.questions.size + 1)
      fol_qst.translations.find_or_create_by(language: language)
             .update(text: '<p>Ulichagua [followup] kama chaguo unalopendelea zaidi.</p>')

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
