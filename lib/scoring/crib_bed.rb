class CribBed
  attr :age, :age_index, :hours_in_bed, :raw_score

  def initialize(age, index, hours, score)
    @age = age
    @age_index = index
    @hours_in_bed = hours
    @raw_score = score
  end
end