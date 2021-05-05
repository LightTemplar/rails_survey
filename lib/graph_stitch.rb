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
img = Magick::Image.new(1897, 554)
background = img.composite(levels, Magick::CenterGravity, Magick::OverCompositeOp)

def write_image(background, filename, identifier, number)
  image = Magick::Image.read(filename).first
  img = image.crop(5, 5, image.columns - 10, image.rows - 10)
  result = background.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
  gc = Magick::Draw.new
  gc.stroke('black')
  if number == 0
    gc.line(330, 172, 1610, 172)
    gc.line(330, 289, 1610, 289)
  elsif number == 1
    gc.line(330, 185, 1610, 185)
    gc.line(330, 291, 1610, 291)
  elsif number == 2
    gc.line(330, 178, 1610, 178)
    gc.line(330, 275, 1610, 275)
  elsif number == 3
    gc.line(330, 178, 1610, 178)
    gc.line(330, 275, 1610, 275)
  elsif number == 4
    gc.line(330, 186, 1610, 186)
    gc.line(330, 291, 1610, 291)
  elsif number == 5
    gc.line(330, 185, 1610, 185)
    gc.line(330, 290, 1610, 290)
  elsif number == 6
    gc.line(330, 185, 1610, 185)
    gc.line(330, 290, 1610, 290)
  end
  gc.draw(result)
  result = result.crop(290, 0, 1550, 550)
  result.write("data/output/#{identifier}-#{number}.png")
end

index = 0
images.each_slice(7) do |slice|
  puts "id: #{identifiers[index]} names: #{slice}"
  [0, 1, 2, 3, 4, 5, 6].each do |number|
    write_image(background, slice[number], identifiers[index], number)
  end
  index += 1
end
