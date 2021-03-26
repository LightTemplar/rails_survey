# frozen_string_literal: true

require 'csv'
require 'rmagick'

identifiers = []
CSV.foreach('data/identifiers.csv') do |row|
  identifiers << row
end
identifiers.flatten!

images = Dir['data/input/*.png'].sort

levels = Magick::Image.read('data/levels.png').first
chopped = levels.crop(150, 10, 1550, 550)

def write_image(overlay, filename, identifier, name)
  image = Magick::Image.read(filename).first
  result = image.composite(overlay, 45, 0, Magick::OverCompositeOp)
  final = result.crop(5, 5, 1545, 565)
  final.write("data/output/#{identifier}-#{name}.png")
end

index = 0
images.each_slice(7) do |slice|
  puts "id: #{identifiers[index]} names: #{slice}"
  [0, 1, 2, 3, 4, 5, 6].each do |number|
    write_image(chopped, slice[number], identifiers[index], number)
  end
  index += 1
end
