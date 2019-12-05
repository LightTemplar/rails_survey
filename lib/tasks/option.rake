# frozen_string_literal: true

task :option, [:filename] => :environment do |_t, args|
  option_set = OptionSet.create(title: 'Centers')
  index = 0
  CSV.foreach(args[:filename], headers: true) do |row|
    puts "row: #{row[3]}"
    option = Option.create(identifier: row[3], text: row[3])
    OptionInOptionSet.create(option_id: option.id, option_set_id: option_set.id, number_in_question: index)
    index += 1
  end
end
