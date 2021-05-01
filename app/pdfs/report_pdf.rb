class ReportPdf
  include Prawn::View
  include PdfUtils
  include Sanitizer

  def initialize(center, score_scheme, language)
    super()
    @center = center
    @score_scheme = score_scheme
    @language = language
    register_fonts
    font 'PT Sans'
    font_size 12
    content
    number_odd_pages
    number_even_pages
  end

  private

  def content
    page_one
    start_new_page
    page_two
    start_new_page
    page_three
    start_new_page
    center_report
    start_new_page
    domain_data
    domain_one
    start_new_page
    domain_two
    start_new_page
    domain_three
    start_new_page
    domain_four
    start_new_page
    domain_five
    start_new_page
    domain_six
    start_new_page
    domain_level_feedback
    start_new_page
    additional_feedback
    start_new_page
    comparison_chart
  end

  def localize_text(key)
    I18n.t("report.#{key}", locale: @language)
  end

  def page_one
    text "<font size='14'><b>#{@center.name}</b></font>", inline_format: true, align: :right
    date = DateTime.now
    text "<font size='14'><b>#{date.strftime('%B %Y')}</b></font>", inline_format: true, align: :right
    font('Avenir Next Condensed') do
      text "<font size='36'><b>#{localize_text('p1_national')}</b></font>", inline_format: true, color: '2F642F', align: :right
      text "<font size='36'><b>#{localize_text('p1_quality')}</b></font>", inline_format: true, color: '2F642F', align: :right
    end
    move_down 10
    image "#{Rails.root}/app/pdfs/images/mother_child_holding_hands.jpg", fit: [512, 288], position: :center
    move_down 100
    image "#{Rails.root}/app/pdfs/images/sponsors.png", fit: [500, 200], position: :center
  end

  def page_two
    font('Avenir Next Condensed') do
      text "<font size='36'><b>#{localize_text('p2_national')}</b></font>", inline_format: true, color: '2F642F', align: :left
      text "<font size='36'><b>#{localize_text('p2_quality')}</b></font>", inline_format: true, color: '2F642F', align: :left
    end
    text localize_text('p2_thanks')
    move_down 10
    text localize_text('p2_partnerships'), inline_format: true
    move_down 10
    text localize_text('p2_report')
    move_down 10
    text localize_text('p2_interpretation')
    move_down 10
    text localize_text('p2_appreciation')
  end

  def page_header_36(key)
    font('Avenir Next Condensed') do
      text "<font size='36'><b>#{localize_text(key)}</b></font>", inline_format: true, color: '2F642F'
    end
  end

  def page_three
    page_header_36('p3_usage')
    text localize_text('p3_report')
    move_down 10
    text localize_text('p3_overview')
    move_down 10
    text localize_text('p3_feedback'), inline_format: true
    move_down 10
    text localize_text('p3_additional'), inline_format: true
    move_down 10
    text localize_text('p3_red_flags')
    move_down 10
    text localize_text('p3_note')
    move_down 10
    text localize_text('p3_recommendations')
    move_down 10
    text localize_text('p3_review')
  end

  def center_details(label, response)
    [{ text: localize_text(label), styles: [:bold], color: '2F642F' }, { text: response }]
  end

  def center_report
    page_header_36('p4_report')
    css = @center.survey_scores.where(score_scheme_id: @score_scheme.id)
    contact = @center.contact(css)
    formatted_text center_details('p4_center', @center.name)
    move_down 10
    formatted_text center_details('p4_director', contact)
    move_down 10
    formatted_text center_details('p4_representative', contact)
    move_down 10
    formatted_text center_details('p4_date', @center.interview_date(css))
    move_down 10
    formatted_text center_details('p4_interview', @center.interview?(css, @score_scheme, @language)) + center_details('p4_observation', @center.observation?(css, @score_scheme, @language))
    move_down 10
    lw = line_width
    sc = stroke_color
    line_width(2)
    stroke_color('2F642F')
    stroke_horizontal_rule
    move_down 5
    stroke_horizontal_rule
    line_width(lw)
    stroke_color(sc)
    move_down 10

    domain_title(localize_text('p4_snapshot'))
    image "#{Rails.root}/files/reports/#{@center.identifier}-0.png", fit: [536, 190], position: :center
    move_down 10
    text "<font size='9'>#{localize_text("p4_#{@center.center_type}")}</font>", inline_format: true
  end

  def domain_data
    centers = @score_scheme.centers.where(center_type: @center.center_type)
    rows, nat_avg_row = Center.sheet_data(@score_scheme, centers)
    header = Center.sheet_header(@score_scheme)
    @scores = {}
    rows.each do |row|
      center_domain_data = {}
      row.each_with_index do |item, index|
        center_domain_data[header[index]] = item
      end
      @scores[row[0]] = center_domain_data
    end
    @nat_avg_scores = {}
    nat_avg_row.each_with_index do |item, index|
      @nat_avg_scores[header[index]] = item
    end
    if is_cda?
      public = @score_scheme.centers.where('center_type = ? and administration = ?', 'CDA', 'Publico')
      pub_rows, public_nat_avg_row = Center.sheet_data(@score_scheme, public)
      @public_scores = {}
      public_nat_avg_row.each_with_index do |item, index|
        @public_scores[header[index]] = item
      end
      private = @score_scheme.centers.where('center_type = ? and administration = ?', 'CDA', 'Privado')
      pri_rows, private_nat_avg_row = Center.sheet_data(@score_scheme, private)
      @private_scores = {}
      private_nat_avg_row.each_with_index do |item, index|
        @private_scores[header[index]] = item
      end
    end
  end

  def domain_title(title)
    font('Avenir Next Condensed') do
      text "<font size='20'><b>#{title}</b></font>", inline_format: true, color: '2F642F'
    end
    move_down 10
  end

  # CDA is residential
  def is_cda?
    @center.center_type == 'CDA'
  end

  def domain_table(title)
    ds = @scores[@center.identifier][title]
    ds = ds.round(2) if ds != ''
    if is_cda?
      table [
        ['', "<b>#{@center.name}</b>", "<b>#{I18n.t('report.public', type: @center.center_type, locale: @language)}</b>",
         "<b>#{I18n.t('report.private', type: @center.center_type, locale: @language)}</b>",
         "<b>#{I18n.t('report.both', type: @center.center_type, locale: @language)}</b>"],
        ["<b>#{localize_text('domain_scores')}</b>", ds, @public_scores[title], @private_scores[title], @nat_avg_scores[title]]
      ], position: :center, cell_style: { align: :center, inline_format: true }
    else
      table [
        ['', "<b>#{@center.name}</b>", "<b>#{I18n.t('report.national', type: @center.center_type, locale: @language)}</b>"],
        ["<b>#{localize_text('domain_scores')}</b>", ds, @nat_avg_scores[title]]
      ], position: :center, cell_style: { align: :center, inline_format: true }
    end
    move_down 10
  end

  def domain_score_graph(title, feedback)
    move_down 10
    ds = @scores[@center.identifier][title]
    ds = ds.round(2) if ds != ''
    text I18n.t('report.d1_score', score: ds, locale: @language), inline_format: true
    move_down 20
    font('Avenir Next Condensed') do
      text "<font size='16'><b>#{feedback}</b></font>", inline_format: true, color: '767171'
    end
    move_down 10
    image "#{Rails.root}/files/reports/#{@center.identifier}-#{title}.png", fit: [536, 190], position: :center
    move_down 5
    text "<font size='9'>#{localize_text('null_score')}</font>", inline_format: true
    move_down 10
  end

  def doing_well(lowest, message)
    if lowest >= 3.01
      text message
      move_down 10
    end
  end

  def highest_scoring_subdomain(title, d_scores, highest, name)
    sd_title = "#{title}.#{d_scores.index(highest) + 1}"
    sd = @score_scheme.subdomains.find_by(title: sd_title)
    tsd_title = @score_scheme.instrument.language == @language ? sd.name : full_sanitizer.sanitize(sd.translated_name(@language))
    text I18n.t('report.d1_highest', name: name, title: tsd_title, highest: highest.round(2), locale: @language), inline_format: true
    move_down 10
    text localize_text(high_low_score_key(sd_title, 'high'))
  end

  def high_low_score_key(sd_title, high_low)
    prefix = 'h'
    prefix = 'l' if high_low == 'low'
    if ['2.6', '3.5', '4.1', '4.6', '5.1', '5.2', '5.3', '5.4', '5.5'].include?(sd_title)
      sd_title[1] = '_'
      is_cda? ? "#{prefix}_#{sd_title}_r" : "#{prefix}_#{sd_title}_n"
    else
      sd_title[1] = '_'
      "#{prefix}_#{sd_title}"
    end
  end

  def low_scoring_subdomains(lowest, d_scores, title)
    if lowest < 3.01
      low_quality
      d_scores.each_with_index do |score, index|
        low_score(title, index, score) if score != '' && score < 3.01
      end
    end
  end

  def low_quality
    move_down 10
    text localize_text('d1_low_quality'), inline_format: true
    move_down 10
  end

  def low_score(title, index, score)
    sd_title = "#{title}.#{index + 1}"
    sd = @score_scheme.subdomains.find_by(title: sd_title)
    name = @score_scheme.instrument.language == @language ? sd.name : full_sanitizer.sanitize(sd.translated_name(@language))
    text I18n.t('report.d1_low_score', name: name, score: score, locale: @language), inline_format: true
    move_down 10
    text localize_text(high_low_score_key(sd_title, 'low'))
    move_down 10
  end

  def red_flags(name)
    move_down 10
    font('Avenir Next Condensed') do
      text "<font size='16'><b>#{name}</b></font>", inline_format: true, color: '767171'
    end
    move_down 20
  end

  def domain_one
    domain_title(localize_text('d1_title'))
    domain_table('1')
    text localize_text('d1_admin'), inline_format: true
    domain_score_graph('1', localize_text('d1_feedback'))
    d_scores = [
      @scores[@center.identifier]['1.1'], @scores[@center.identifier]['1.2'],
      @scores[@center.identifier]['1.3'], @scores[@center.identifier]['1.4']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, localize_text('d1_all_well'))
    highest = d_scores_clean.max
    highest_scoring_subdomain('1', d_scores, highest, localize_text('d1_name'))
    low_scoring_subdomains(lowest, d_scores, '1')
    red_flags(localize_text('d1_red_flags'))
  end

  def domain_two
    domain_title(localize_text('d2_title'))
    domain_table('2')
    text localize_text('d2_admin'), inline_format: true
    domain_score_graph('2', localize_text('d2_feedback'))
    d_scores = [
      @scores[@center.identifier]['2.1'], @scores[@center.identifier]['2.2'],
      @scores[@center.identifier]['2.3'], @scores[@center.identifier]['2.4'],
      @scores[@center.identifier]['2.5'], @scores[@center.identifier]['2.6'],
      @scores[@center.identifier]['2.7'], @scores[@center.identifier]['2.8'],
      @scores[@center.identifier]['2.9']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, localize_text('d2_all_well'))
    highest = d_scores_clean.max
    highest_scoring_subdomain('2', d_scores, highest, localize_text('d2_name'))
    low_scoring_subdomains(lowest, d_scores, '2')
    red_flags(localize_text('d2_red_flags'))
  end

  def domain_three
    domain_title(localize_text('d3_title'))
    domain_table('3')
    text localize_text('d3_admin'), inline_format: true
    domain_score_graph('3', localize_text('d3_feedback'))
    d_scores = [
      @scores[@center.identifier]['3.1'], @scores[@center.identifier]['3.2'],
      @scores[@center.identifier]['3.3'], @scores[@center.identifier]['3.4'],
      @scores[@center.identifier]['3.5'], @scores[@center.identifier]['3.6']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, localize_text('d3_all_well'))
    highest = d_scores_clean.max
    highest_scoring_subdomain('3', d_scores, highest, localize_text('d3_name'))
    low_scoring_subdomains(lowest, d_scores, '3')
    red_flags(localize_text('d3_red_flags'))
  end

  def domain_four
    domain_title(localize_text('d4_title'))
    domain_table('4')
    text localize_text('d4_admin'), inline_format: true
    domain_score_graph('4', localize_text('d4_feedback'))
    d_scores = [
      @scores[@center.identifier]['4.1'], @scores[@center.identifier]['4.2'],
      @scores[@center.identifier]['4.3'], @scores[@center.identifier]['4.4'],
      @scores[@center.identifier]['4.5'], @scores[@center.identifier]['4.6']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, localize_text('d4_all_well'))
    highest = d_scores_clean.max
    highest_scoring_subdomain('4', d_scores, highest, localize_text('d4_name'))
    low_scoring_subdomains(lowest, d_scores, '4')
    red_flags(localize_text('d4_red_flags'))
  end

  def domain_five
    domain_title(localize_text('d5_title'))
    domain_table('5')
    text localize_text('d5_admin'), inline_format: true
    domain_score_graph('5', localize_text('d5_feedback'))
    d_scores = [
      @scores[@center.identifier]['5.1'], @scores[@center.identifier]['5.2'],
      @scores[@center.identifier]['5.3'], @scores[@center.identifier]['5.4'],
      @scores[@center.identifier]['5.5'], @scores[@center.identifier]['5.6'],
      @scores[@center.identifier]['5.7'], @scores[@center.identifier]['5.8']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, localize_text('d5_all_well'))
    highest = d_scores_clean.max
    highest_scoring_subdomain('5', d_scores, highest, localize_text('d5_name'))
    low_scoring_subdomains(lowest, d_scores, '5')
    red_flags(localize_text('d5_red_flags'))
  end

  def domain_six
    domain_title(localize_text('d6_title'))
    domain_table('6')
    text localize_text('d6_admin'), inline_format: true
    domain_score_graph('6', localize_text('d6_feedback'))
    d_scores = [
      @scores[@center.identifier]['6.1'], @scores[@center.identifier]['6.2'],
      @scores[@center.identifier]['6.3']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, localize_text('d6_all_well'))
    highest = d_scores_clean.max
    highest_scoring_subdomain('6', d_scores, highest, localize_text('d6_name'))
    low_scoring_subdomains(lowest, d_scores, '6')
    red_flags(localize_text('d6_red_flags'))
  end

  def domain_level_feedback
    domain_title(localize_text('dl_feedback'))
    domain_one_feedback
    move_down 10
    domain_two_feedback
    move_down 10
    domain_three_feedback
    move_down 10
    domain_four_feedback
    move_down 10
    domain_five_feedback
    move_down 10
    domain_six_feedback
  end

  def domain_header(name)
    font('Avenir Next Condensed') do
      text "<font size='18'><b>#{name}</b></font>", inline_format: true, color: '767171'
    end
    move_down 5
  end

  def domain_one_feedback
    domain_header(localize_text('d1_name'))
    text localize_text('d1_overview')
    domain_feedback('1')
  end

  def domain_two_feedback
    domain_header(localize_text('d2_name'))
    text localize_text('d2_overview')
    domain_feedback('2')
  end

  def domain_three_feedback
    domain_header(localize_text('d3_name'))
    text localize_text('d3_overview')
    domain_feedback('3')
  end

  def domain_four_feedback
    domain_header(localize_text('d4_name'))
    text localize_text('d4_overview')
    domain_feedback('4')
  end

  def domain_five_feedback
    domain_header(localize_text('d5_name'))
    text localize_text('d5_overview')
    domain_feedback('5')
  end

  def domain_six_feedback
    domain_header(localize_text('d6_name'))
    text localize_text('d6_overview')
    domain_feedback('6')
  end

  def domain_feedback(title)
    ds = @scores[@center.identifier][title]
    ds = ds.round(2) if ds != ''
    move_down 10
    case ds
    when 1.0..3.0
      overview('low', title)
      inferior_quality(title)
    when 3.01..5.0
      overview('mid', title)
      mid_quality(title)
    when 5.01..7.0
      overview('high', title)
      high_quality(title)
    else
      text 'NO SCORE'
    end
  end

  def overview(key, title)
    text I18n.t("report.#{key}", name: localize_text("d#{title}_name"), locale: @language)
  end

  def bullet_points(range, prefix)
    move_down 10
    indent(20) do
      range.each do |index|
        stroke_rectangle [bounds.left, cursor - 5], 8, 8
        indent(23) do
          pad(1) { text localize_text("#{prefix}_#{index}") }
        end
      end
    end
  end

  def high_quality(title)
    case title
    when '1'
      bullet_points(1..5, 'd1_high')
    when '2'
      if is_cda?
        bullet_points(1..17, 'd2_high_res')
      else
        bullet_points(1..15, 'd2_high_non')
      end
    when '3'
      if is_cda?
        bullet_points(1..8, 'd3_high_res')
      else
        bullet_points(1..7, 'd3_high_non')
      end
    when '4'
      bullet_points(1..12, 'd4_high')
    when '5'
      if is_cda?
        bullet_points(1..17, 'd5_high_res')
      else
        bullet_points(1..6, 'd5_high_non')
      end
    when '6'
      bullet_points(1..8, 'd6_high')
    else
      text 'OUT OF RANGE'
    end
  end

  def mid_quality(title)
    case title
    when '1'
      bullet_points(1..7, 'd1_mid')
    when '2'
      if is_cda?
        bullet_points(1..14, 'd2_mid_res')
      else
        bullet_points(1..13, 'd2_mid_non')
      end
    when '3'
      if is_cda?
        bullet_points(1..7, 'd3_mid_res')
      else
        bullet_points(1..6, 'd3_mid_non')
      end
    when '4'
      bullet_points(1..14, 'd4_mid')
    when '5'
      if is_cda?
        bullet_points(1..15, 'd5_mid_res')
      else
        bullet_points(1..6, 'd5_mid_non')
      end
    when '6'
      bullet_points(1..11, 'd6_mid')
    else
      text 'OUT OF RANGE'
    end
  end

  def inferior_quality(title)
    case title
    when '1'
      bullet_points(1..7, 'd1_low')
    when '2'
      if is_cda?
        bullet_points(1..10, 'd2_low_res')
      else
        bullet_points(1..9, 'd2_low_non')
      end
    when '3'
      if is_cda?
        bullet_points(1..7, 'd3_low_res')
      else
        bullet_points(1..6, 'd3_low_non')
      end
    when '4'
      bullet_points(1..11, 'd4_low')
    when '5'
      if is_cda?
        bullet_points(1..12, 'd5_low_res')
      else
        bullet_points(1..6, 'd5_low_non')
      end
    when '6'
      bullet_points(1..11, 'd6_low')
    else
      text 'OUT OF RANGE'
    end
  end

  def additional_feedback
    domain_title(localize_text('additional_feedback'))
    text localize_text('additional_comments')
  end

  def comparison_chart
    domain_title(localize_text('comparison_chart'))
    text localize_text("#{@center.center_type}_comparison")
    move_down 10
    data = if is_cda?
             [
               ['', @center.name, I18n.t('report.public', type: @center.center_type, locale: @language),
                I18n.t('report.private', type: @center.center_type, locale: @language),
                I18n.t('report.both', type: @center.center_type, locale: @language)],
               [localize_text('center_score'), @scores[@center.identifier]['Score'], @public_scores['Score'], @private_scores['Score'], @nat_avg_scores['Score']]
             ]
           else
             [
               ['', @center.name, I18n.t('report.national', type: @center.center_type, locale: @language)],
               [localize_text('center_score'), @scores[@center.identifier]['Score'], @nat_avg_scores['Score']]
             ]
           end
    @score_scheme.domains.sort_by { |domain| domain.title.to_i }.each do |domain|
      ds = @scores[@center.identifier][domain.title]
      ds = ds.round(2) if ds != ''
      if is_cda?
        data << [localize_text("d#{domain.title}_title"), '', '', '', '']
        data << [localize_text('domain_score'), ds, @public_scores[domain.title], @private_scores[domain.title], @nat_avg_scores[domain.title]]
      else
        data << [localize_text("d#{domain.title}_title"), '', '']
        data << [localize_text('domain_score'), ds, @nat_avg_scores[domain.title]]
      end
      domain.subdomains.sort_by { |subdomain| subdomain.title.to_f }.each do |subdomain|
        next if subdomain.title == '1.5' || subdomain.title == '5.9'

        sds = @scores[@center.identifier][subdomain.title]
        sds = sds.round(2) if sds != ''
        name = @score_scheme.instrument.language == @language ? subdomain.title_name : full_sanitizer.sanitize(subdomain.translated_title_name(@language))
        data << if is_cda?
                  [name, sds, @public_scores[subdomain.title], @private_scores[subdomain.title], @nat_avg_scores[subdomain.title]]
                else
                  [name, sds, @nat_avg_scores[subdomain.title]]
                end
      end
    end

    font('Courier', size: 10) do
      table(data) do
        cells.borders = []
        cells.align = :center
        columns(0..4).borders = %i[left right]

        row(0..3).borders = %i[left top right bottom]
        row(0..3).font_style = :bold
        row(2).background_color = 'D9D9D9'
        row(3).columns(0).font_style = :bold_italic

        row(8).borders = %i[left top right]
        row(8).font_style = :bold
        row(8).background_color = 'D9D9D9'
        row(9).borders = %i[left right bottom]
        row(9).columns(0).font_style = :bold_italic

        row(19).borders = %i[left top right]
        row(19).font_style = :bold
        row(19).background_color = 'D9D9D9'
        row(20).borders = %i[left right bottom]
        row(20).columns(0).font_style = :bold_italic

        row(27).borders = %i[left top right]
        row(27).font_style = :bold
        row(27).background_color = 'D9D9D9'
        row(28).borders = %i[left right bottom]
        row(28).columns(0).font_style = :bold_italic

        row(35).borders = %i[left top right]
        row(35).font_style = :bold
        row(35).background_color = 'D9D9D9'
        row(36).borders = %i[left right bottom]
        row(36).columns(0).font_style = :bold_italic

        row(45).borders = %i[left top right]
        row(45).font_style = :bold
        row(45).background_color = 'D9D9D9'
        row(46).borders = %i[left right bottom]
        row(46).columns(0).font_style = :bold_italic

        row(49).borders = %i[left right bottom]

        data.each_with_index do |datum, index|
          next if index == 0 || (datum[1] == '' && datum[2] == '')

          datum.each_with_index do |score, ind|
            next if ind == 0 || score == ''

            row(index).columns(ind).background_color = 'FEC15D' if score > 3.0 && score < 5.01
            row(index).columns(ind).background_color = 'F06A78' if score < 3.01
          end
        end
      end
    end
    move_down 20
    text localize_text('no_color')
    text localize_text('orange_color'), inline_format: true
    text localize_text('red_color'), inline_format: true
  end
end
