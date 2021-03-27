# frozen_string_literal: false

Axlsx::Axis.class_eval do
  attr_reader :dash

  attr_writer :dash

  def to_xml_string(str = '')
    str << ('<c:axId val="' << @id.to_s << '"/>')
    @scaling.to_xml_string str
    str << ('<c:delete val="' << @delete.to_s << '"/>')
    str << ('<c:axPos val="' << @ax_pos.to_s << '"/>')
    str << '<c:majorGridlines>'
    # TODO: shape properties need to be extracted into a class
    if gridlines == false
      str << '<c:spPr>'
      str << '<a:ln>'
      str << '<a:noFill/>'
      str << '</a:ln>'
      str << '</c:spPr>'
    end
    str << '<c:spPr><a:ln><a:solidFill><a:srgbClr val="cccccc"/></a:solidFill><a:prstDash val="dash"/></a:ln></c:spPr>' if @dash
    str << '</c:majorGridlines>'
    @title&.to_xml_string(str)
    # Need to set sourceLinked to 0 if we're setting a format code on this row
    # otherwise it will never take, as it will always prefer the 'General' formatting
    # of the cells themselves
    str << ('<c:numFmt formatCode="' << @format_code << '" sourceLinked="' << (@format_code.eql?('General') ? '1' : '0') << '"/>')
    str << '<c:majorTickMark val="none"/>'
    str << '<c:minorTickMark val="none"/>'
    str << ('<c:tickLblPos val="' << @tick_lbl_pos.to_s << '"/>')
    # TODO: - this is also being used for series colors
    # time to extract this into a class spPr - Shape Properties
    if @color
      str << '<c:spPr><a:ln><a:solidFill>'
      str << ('<a:srgbClr val="' << @color << '"/>')
      str << '</a:solidFill></a:ln></c:spPr>'
    end
    # some potential value in implementing this in full. Very detailed!
    str << ('<c:txPr><a:bodyPr rot="' << @label_rotation.to_s << '"/><a:lstStyle/><a:p><a:pPr><a:defRPr/></a:pPr><a:endParaRPr/></a:p></c:txPr>')
    str << ('<c:crossAx val="' << @cross_axis.id.to_s << '"/>')
    str << ('<c:crosses val="' << @crosses.to_s << '"/>')
end
end
