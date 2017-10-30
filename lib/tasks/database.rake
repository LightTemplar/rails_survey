namespace :db do
  desc "Create a lot of data in the database to test syncing performance"
  task muchdata: :environment do
    10.times do |i_n|
      i = Instrument.create!(title: "Instrument #{i_n}",
        language: Settings.languages.sample,
        alignment: "left"
      )
      p "Created #{i.title}"
      10000.times do |q_n|
        question_type = Settings.question_types.sample
        question = i.questions.create!(text: "Question #{q_n}",
          question_identifier: "#{i_n}_q_#{q_n}",
          question_type: Settings.question_types.sample
        )
        if Settings.question_with_options.include? question_type
          5.times do |o_n|
            question.options.create!(text: "Option #{o_n}")
          end
        end
      end
    end
  end

  task sets: :environment do
    10.times do |t|
      os = OptionSet.create!(title: "Option Set #{t}")
      3.times do |o_n|
        o = Option.create!(text: "Option #{t}_#{o_n}", option_set_id: os.id)
      end
    end
    10.times do |t|
      qs = QuestionSet.create!(title: "Question Set #{t}")
      5.times do |q_n|
        q = Question.create!(
          text: "Question #{q_n}",
          question_identifier: "#{t}_q_#{q_n}",
          question_type: Settings.question_types.sample,
          question_set_id: qs.id
        )
        if Settings.question_with_options.include? q.question_type
          os = OptionSet.find(OptionSet.ids.shuffle.first)
          q.option_set_id = os.id
          q.save!
        end
      end
    end
  end

  task default_user: :environment do
    u = User.new
    u.email = 'user@example.com'
    u.password = u.password_confirmation = 'Password1'
    u.save!
    %w(user admin manager analyst translator super_admin).each do |name|
      role = Role.find_by_name(name)
      Role.create(name: name) if role.nil?
    end
    u.roles << Role.all
    p = Project.create!(name: 'Test Project', description: 'Test Project')
    u.projects << p
    u.save!
  end
end
