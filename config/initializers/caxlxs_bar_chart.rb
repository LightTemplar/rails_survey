# frozen_string_literal: false

Axlsx::BarChart.class_eval do
  def to_xml_string(str = '')
    super(str) do
      str << '<c:barChart>'
      str << ('<c:barDir val="' << bar_dir.to_s << '"/>')
      str << ('<c:grouping val="' << grouping.to_s << '"/>')
      str << ('<c:varyColors val="' << vary_colors.to_s << '"/>')
      @series.each { |ser| ser.to_xml_string(str) }
      @d_lbls&.to_xml_string(str)
      str << '<c:gapWidth val="50"/>'
      str << ('<c:gapDepth val="' << @gap_depth.to_s << '"/>') unless @gap_depth.nil?
      str << ('<c:shape val="' << @shape.to_s << '"/>') unless @shape.nil?
      axes.to_xml_string(str, ids: true)
      str << '</c:barChart>'
      axes.to_xml_string(str)
    end
  end
end
