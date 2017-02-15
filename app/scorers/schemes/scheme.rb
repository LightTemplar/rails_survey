# Base scoring scheme
class Scheme
  def option_ids(question, response)
    options = []
    response.try(:text).split(',').each do |text|
      options << option_at_index(question, text.to_i).try(:id)
    end
    options
  end

  def option_at_index(question, index)
    question.non_special_options[index]
  end
end
