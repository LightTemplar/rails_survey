namespace :instrument do
  task :copy, [:instrument_id, :project_id] => [:environment] do |t, args|
    instrument = Instrument.find(args[:instrument_id].to_i)
    project_id = args[:project_id]

    i = instrument.dup
    i.project_id = project_id.to_i
    i.published = false
    i.save!

    instrument.rules.each do |rule|
      r = rule.dup
      r.instrument_id = i.id
      r.save!
    end

    instrument.translations.each do |translation|
      t = translation.dup
      t.instrument_id = i.id
      t.save!
    end

    instrument.grids.each do |grid|
      g = grid.dup
      g.instrument_id = i.id
      g.save!

      grid.grid_labels.each do |grid_label|
        gl = grid_label.dup
        gl.grid_id = g.id
        gl.option_id = -(gl.option_id)
        gl.save!
      end

      grid.questions.each do |question|
        q = question.dup
        q.question_identifier = "#{question.question_identifier}_#{project_id}"
        q.grid_id = g.id
        q.following_up_question_identifier = "#{question.following_up_question_identifier}_#{project_id}" if question.following_up_question_identifier
        q.instrument_id = i.id
        q.save!
      end
    end

    instrument.sections.each do |section|
      s = section.dup
      s.instrument_id = i.id
      s.save!

      section.translations.each do |translation|
        t = translation.dup
        t.section_id = s.id
        t.save!
      end

      section.questions.each do |question|
        q = Question.find_by_question_identifier("#{question.question_identifier}_#{project_id}")
        unless q
          q = question.dup
          q.question_identifier = "#{question.question_identifier}_#{project_id}"
          q.section_id = s.id
          q.following_up_question_identifier = "#{question.following_up_question_identifier}_#{project_id}" if question.following_up_question_identifier
          q.instrument_id = i.id
          q.save!
        end
      end
    end

    instrument.questions.each do |question|
      q = Question.find_by_question_identifier("#{question.question_identifier}_#{project_id}")
      unless q
        q = question.dup
        q.question_identifier = "#{question.question_identifier}_#{project_id}"
        q.following_up_question_identifier = "#{question.following_up_question_identifier}_#{project_id}" if question.following_up_question_identifier
        q.instrument_id = i.id
        q.save!
      end

      question.images.each do |image|
        im = image.dup
        im.question_id = q.id
        im.save!
      end

      question.translations.each do |translation|
        t = translation.dup
        t.question_id = q.id
        t.save!
      end

      question.options.each do |option|
        o = option.dup
        o.next_question = "#{option.next_question}_#{project_id}" if option.next_question
        o.question_id = q.id
        o.save!

        option.skips.each do |skip|
          s = skip.dup
          s.question_identifier = "#{skip.question_identifier}_#{project_id}" if skip.question_identifier
          s.option_id = o.id
          s.save!
        end

        option.translations.each do |translation|
          t = translation.dup
          t.option_id = o.id
          t.save!
        end

        if option.grid_label
          gl = GridLabel.where(option_id: -(option.id)).first
          gl.option_id = o.id if gl
          gl.save!
        end
      end
    end
  end
end