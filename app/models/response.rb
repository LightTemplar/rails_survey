class Response < ActiveRecord::Base
  belongs_to :question

  def survey
    Survey.find_by_uuid(survey_uuid)
  end

  def to_s
    if question.options.empty?
      text
    else
      question.options[text.to_i].to_s
    end
  end

  def self.responses_by_hour
    map = {}
    (0..23).each do |hour|
      map[hour] = 0
    end
    responses = Response.all
    responses.each do |response|
      hr = response.created_at.hour
      old_value = map[hr]
      map[hr] = old_value + 1
    end
    map
  end

  def self.responses_by_question_ids(question_ids)
    responses = {}
    map = {}
    question_ids.each do |id|
      words = Response.includes(:question).where('question_id == ?', id)
      answers = []
      question_identifier = ''
      words.each do |word|
        question_identifier = word.question.question_identifier
        answers << word.to_s
      end
      responses[question_identifier] = answers
    end
    responses.each do |question_number, response_array|
      hash = Hash.new(0)
      response_array.each { |word| hash[word] += 1 }
      map[question_number] = hash
    end
    map
  end

  def grouped_responses
    self.group(:created_at)
  end

end
