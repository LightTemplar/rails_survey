Gruff::Base.class_eval do
  # Draws horizontal background lines and labels
  def draw_line_markers
    return if @hide_line_markers

    increment_scaled = @graph_height.to_f / (@spread / @increment)

    # Draw horizontal line markers and annotate with numbers
    (0..marker_count).each do |index|
      y = @graph_top + @graph_height - index.to_f * increment_scaled

      if [0, 3, 5].include?(index)
        line_renderer = Gruff::Renderer::Line.new(color: @marker_color, shadow_color: @marker_shadow_color)
        line_renderer.render(@graph_left, y, @graph_right, y)
      else
        dash_line_renderer = Gruff::Renderer::DashLine.new(color: @marker_color, width: 0.1)
        dash_line_renderer.render(@graph_left, y, @graph_right, y)
      end

      next if @hide_line_numbers

      marker_label = BigDecimal(index.to_s) * BigDecimal(@increment.to_s) + BigDecimal(minimum_value.to_s)
      label = y_axis_label(marker_label, @increment)
      text_renderer = Gruff::Renderer::Text.new(label, font: @font, size: @marker_font_size, color: @font_color)
      text_renderer.add_to_render_queue(@graph_left - 15.0, 1.0, 0.0, y, Magick::EastGravity)
    end
  end
end

Gruff::Renderer::DashLine.class_eval do
  def render(start_x, start_y, end_x, end_y)
    draw = Gruff::Renderer.instance.draw
    draw.push
    draw.stroke_color(@color)
    draw.fill_opacity(0.0)
    draw.stroke_dasharray(1, 2)
    draw.stroke_width(@width)
    draw.line(start_x, start_y, end_x, end_y)
    draw.pop
  end
end

Gruff::Bar.class_eval do
  # Value to avoid completely overwriting the coordinate axis
  AXIS_MARGIN = 0.5

  def draw_bars
    # Setup spacing.
    #
    # Columns sit side-by-side.
    @bar_spacing ||= @spacing_factor # space between the bars

    bar_width = (@graph_width - calculate_spacing) / (column_count * store.length).to_f
    padding = (bar_width * (1 - @bar_spacing)) / 2

    # Setup the BarConversion Object
    conversion = Gruff::BarConversion.new(
      top: @graph_top, bottom: @graph_bottom,
      minimum_value: minimum_value, maximum_value: maximum_value, spread: @spread
    )

    # iterate over all normalised data
    store.norm_data.each_with_index do |data_row, row_index|
      data_row.points.each_with_index do |data_point, point_index|
        group_spacing = @group_spacing * @scale * point_index

        # Use incremented x and scaled y
        # x
        left_x = @graph_left + (bar_width * (row_index + point_index + ((store.length - 1) * point_index))) + padding + group_spacing
        right_x = left_x + bar_width * @bar_spacing
        # y
        left_y, right_y = conversion.get_top_bottom_scaled(data_point)

        # create new bar
        rect_renderer = Gruff::Renderer::Rectangle.new(color: data_row.color)
        rect_renderer.render(left_x, left_y - AXIS_MARGIN, right_x, right_y - AXIS_MARGIN)

        # Calculate center based on bar_width and current row
        label_center = @graph_left + group_spacing + (store.length * bar_width * point_index) + (store.length * bar_width / 2.0)

        # Subtract half a bar width to center left if requested
        draw_label(label_center, point_index)
        next unless @show_labels_for_bar_values

        next unless store.data[row_index].points[point_index] != 0.0

        bar_value_label = Gruff::BarValueLabel::Bar.new([left_x, left_y, right_x, right_y], store.data[row_index].points[point_index])
        bar_value_label.prepare_rendering(@label_formatting, bar_width) do |x, y, text|
          draw_value_label(x, y, text, true)
        end
      end
    end

    # Draw the last label if requested
    draw_label(@graph_right, column_count, Magick::NorthWestGravity) if @center_labels_over_point
  end
end
