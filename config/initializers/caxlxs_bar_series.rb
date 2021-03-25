# frozen_string_literal: false

# This code is borrowed from
# https://github.com/kiskoza/caxlsx/blob/0e3c8b59b82229128c1d04e99e4c0b9f57b95d6e/lib/axlsx/drawing/bar_series.rb

# encoding: UTF-8

Axlsx::BarSeries.class_eval do
  attr_reader :color

  attr_writer :color

  def to_xml_string(str = '')
    super(str) do
      colors.each_with_index do |c, index|
        str << '<c:dPt>'
        str << ('<c:idx val="' << index.to_s << '"/>')
        str << '<c:spPr><a:solidFill>'
        str << ('<a:srgbClr val="' << c << '"/>')
        str << '</a:solidFill></c:spPr></c:dPt>'
      end

      if color
        str << '<c:spPr><a:solidFill>'
        str << ('<a:srgbClr val="' << color << '"/>')
        str << '</a:solidFill>'
        str << '</c:spPr>'
      end

      @labels&.to_xml_string(str)
      @data&.to_xml_string(str)
      # this is actually only required for shapes other than box
      str << ('<c:shape val="' << shape.to_s << '"></c:shape>')
    end
  end
end
