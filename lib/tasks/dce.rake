# frozen_string_literal: true

desc 'Create DCE tasks from CSV files'
task :dce, [:project_id] => :environment do |_t, args|
  project = Project.find_by(id: args[:project_id].to_i)
  if project.nil?
    Rake::Task['setup'].reenable
    Rake::Task['setup'].invoke
    project = Project.first
  end
  instrument = Instrument.create(project_id: project.id, published: true,
                                 title: "DCE Tasks #{Time.now.to_i}", language: 'en')
  puts instrument.inspect
  files = ["#{Rails.root}/files/dce/DCEMergeMen.csv", "#{Rails.root}/files/dce/DCEMergeWomen.csv"]
  files.each do |filename|
    puts "name = #{filename}"
    CSV.foreach(filename, headers: true) do |row|
      break if row[0].blank?

      question_set = QuestionSet.find_or_create_by(title: filename.split('/').last.split('.').first)
      puts question_set.inspect
      instrument.reload
      section = instrument.sections.create_with(position: instrument.sections.size + 1)
                          .find_or_create_by(title: row[4])
      puts section.inspect
      question_set.reload
      folder = question_set.folders.create_with(position: question_set.folders.size).find_or_create_by(title: row[4])
      puts folder.inspect
      section.reload
      instrument.reload
      display = section.displays.create_with(instrument_id: instrument.id,
                                             position: section.displays.size + 1,
                                             instrument_position: instrument.displays.size + 1)
                       .find_or_create_by(title: "#{row[4]}-#{row[6]}")
      puts display.inspect
      folder.reload
      question = folder.questions.create_with(text: '<p>Please consider the following three options</p> <p>If these options ' \
                                                    'were available to you right now, at no cost, which option would ' \
                                                    'you prefer: A, B or C</p>',
                                              question_type: 'CHOICE_TASK',
                                              question_set_id: folder.question_set_id,
                                              position: folder.questions.size + 1)
                       .find_or_create_by(question_identifier: "#{row[3]}-#{row[4]}")
      option_set = OptionSet.find_or_create_by(title: "#{row[3]}-#{row[4]}")
      question.option_set_id = option_set.id
      question.save
      display.reload
      instrument.reload
      display.instrument_questions.create_with(instrument_id: instrument.id,
                                               question_id: question.id,
                                               position: display.instrument_questions.size + 1,
                                               number_in_instrument: instrument.instrument_questions.size + 1)
             .find_or_create_by(identifier: "#{row[3]}-#{row[4]}")

      %w[A B C].each do |letter|
        Option.find_or_create_by(identifier: "#{row[3]}-#{row[4]}-#{letter}") do |option|
          option.text = "Option #{letter}"
          option.save
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
              oios.option_collages.create_with(position: index).find_or_create_by(collage_id: collage.id)
              t_option = Option.create_with(text: row[t_cell]).find_or_create_by(identifier: row[t_cell])
              collage.diagrams.create_with(position: 0).find_or_create_by(option_id: t_option.id)
              i_option = Option.create_with(text: row[i_cell]).find_or_create_by(identifier: row[i_cell])
              collage.diagrams.create_with(position: 1).find_or_create_by(option_id: i_option.id)
              index += 1
            end
          end
        end
      end
    end
  end
end
