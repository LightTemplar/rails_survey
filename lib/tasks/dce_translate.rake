# frozen_string_literal: true

desc 'Import DCE instrument translations from CSV file'
task :dce_translate, [:filename] => :environment do |_t, args|
  index = 0
  instrument = nil
  language = nil
  CSV.foreach(args[:filename], headers: false) do |row|
    puts "#{index} => #{row[0]}"
    if index.zero?
      puts "ID: #{row[1]}"
      instrument = Instrument.find(row[1].strip.to_i)
      puts "Instrument: #{instrument.title}"
    end
    if index == 5
      # 7 = swahili, 8 = amharic, 9 = khmer
      language = row[9].strip
      puts "Language: #{language}"
    end
    if index > 5
      puts "Row: #{row}"
      if row[3].present? && row[5].present? && row[9].present?
        question = Question.find_by(question_identifier: row[3].strip)
        question.translations.find_or_create_by(language: language).update(text: row[9].strip) if question
      elsif row[3].blank? && row[5].present? && row[9].present?
        options = Option.where(text: row[5].strip)
        options = Option.where(text: "<p>#{row[5].strip}</p>") if options.blank?
        options.each do |option|
          option.translations.find_or_create_by(language: language)
                .update(text: row[9].strip)
        end
      end
    end
    index += 1
  end
end
