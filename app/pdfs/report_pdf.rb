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
    image "#{Rails.root}/files/reports/#{@center.identifier}-0.png", fit: [564, 200], position: :center
    move_down 10
    text "<font size='10'>#{localize_text("p4_#{@center.center_type}")}</font>", inline_format: true
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

  def is_cda?
    @center.center_type == 'CDA'
  end

  def domain_table(title)
    if is_cda?
      table [
        ['', "<b>#{@center.name}</b>", "<b>#{@center.center_type} #{localize_text('public')}</b>",
         "<b>#{@center.center_type} #{localize_text('private')}</b>", "<b>#{@center.center_type} #{localize_text('both')}</b>"],
        ["<b>#{localize_text('domain_scores')}</b>", @scores[@center.identifier][title], @public_scores[title], @private_scores[title], @nat_avg_scores[title]]
      ], position: :center, cell_style: { align: :center, inline_format: true }
    else
      table [
        ['', "<b>#{@center.name}</b>", "<b>#{@center.center_type} #{localize_text('national')}</b>"],
        ["<b>#{localize_text('domain_scores')}</b>", @scores[@center.identifier][title], @nat_avg_scores[title]]
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
    image "#{Rails.root}/files/reports/#{@center.identifier}-#{title}.png", fit: [564, 200], position: :center
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
    text I18n.t('report.d1_highest', name: name, title: tsd_title, highest: highest, locale: @language), inline_format: true
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
    text 'Within this domain, this center is providing <b>low quality</b> care in the following subdomains, and improvement is necessary.', inline_format: true
    move_down 10
  end

  def low_score(title, index, score)
    sd_title = "#{title}.#{index + 1}"
    sd = @score_scheme.subdomains.find_by(title: sd_title)
    text "Your center scored <b>#{score}</b> in the <b>#{sd_title}</b> subdomain. [#{sd.name} – low score]", inline_format: true
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
    red_flags('Domain 1: Administration & Governance Red Flags')
  end

  def domain_two
    domain_title('Domain 2: Basic Needs')
    domain_table('2')
    text 'The <b>Basic Needs</b> domain measures the availability and accessibility of resources, and the ability of the center to meet the children’s basic needs. This domain considers Food Security & Nutrition, Safety & Security, Disaster Preparedness, Hygiene, Sleep Hygiene, Health Care, Educational Opportunities, Social/Emotional Care, and Disability Services. Ideally, the center is able to provide for the basic needs of the children in care, providing a healthy foundation for each child to grow.', inline_format: true
    domain_score_graph('2', 'Domain 2: Basic Needs Subdomain Feedback')
    d_scores = [
      @scores[@center.identifier]['2.1'], @scores[@center.identifier]['2.2'],
      @scores[@center.identifier]['2.3'], @scores[@center.identifier]['2.4'],
      @scores[@center.identifier]['2.5'], @scores[@center.identifier]['2.6'],
      @scores[@center.identifier]['2.7'], @scores[@center.identifier]['2.8'],
      @scores[@center.identifier]['2.9']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, 'In your center, all domain 2 subdomains received scores higher than 3.01. This indicates that your center is meeting many of the requirements needed to provide good care in Food Security & Nutrition, Safety & Security, Disaster Preparedness, Hygiene, Sleep Hygiene, Health Care, Educational Opportunities, Social/Emotional Care, and Disability Services.')
    highest = d_scores_clean.max
    highest_scoring_subdomain('2', d_scores, highest, 'Basic Needs')
    low_scoring_subdomains(lowest, d_scores, '2')
    red_flags('Domain 2: Basic Needs Red Flags')
  end

  def domain_three
    domain_title('Domain 3: Child Protection')
    domain_table('3')
    text 'The <b>Child Protection</b> domain is a measure of the center’s efforts to keep children safe from harm, including violence, exploitation, abuse, and neglect. This domain considers Codes of Conduct, Reporting Process, Children’s Privacy, Prevention of Abuse and Neglect, Gatekeeping, and Case Management. Ideally, leadership are aware of the vulnerabilities of the children in care, and take all possible measures to prevent or address any further harm.', inline_format: true
    domain_score_graph('3', 'Domain 3: Child Protection Subdomain Feedback')
    d_scores = [
      @scores[@center.identifier]['3.1'], @scores[@center.identifier]['3.2'],
      @scores[@center.identifier]['3.3'], @scores[@center.identifier]['3.4'],
      @scores[@center.identifier]['3.5'], @scores[@center.identifier]['3.6']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, 'In your center, all domain 3 subdomains received scores higher than 3.01. This indicates that your center is meeting many of the requirements needed to protect children through Codes of Conduct, Reporting Process, Children’s Privacy, Prevention of Abuse and Neglect, Gatekeeping, and Case Management.')
    highest = d_scores_clean.max
    highest_scoring_subdomain('3', d_scores, highest, 'Child Protection')
    low_scoring_subdomains(lowest, d_scores, '3')
    red_flags('Domain 3: Child Protection Red Flags')
  end

  def domain_four
    domain_title('Domain 4: Child-Caregiver Relationships')
    domain_table('4')
    text 'The <b>Child-Caregiver Relationships</b> domain measures the quality of the relationship between the children and their caregivers. This domain considers Continuity of Care, Attachment Behaviors, Trauma Informed Caregiving, Caregiving Activities/Routines, Communication, and Shared Control. Ideally, the center fosters healthy positive relationships between children and their caregivers, enabling each child to form a stable and secure attachment with at least one consistent, supportive adult.', inline_format: true
    domain_score_graph('4', 'Domain 4: Child-Caregiver Relationships Subdomain Feedback')
    d_scores = [
      @scores[@center.identifier]['4.1'], @scores[@center.identifier]['4.2'],
      @scores[@center.identifier]['4.3'], @scores[@center.identifier]['4.4'],
      @scores[@center.identifier]['4.5'], @scores[@center.identifier]['4.6']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, 'In your center, all domain 4 subdomains received scores higher than 3.01. This indicates that your center is meeting many of the requirements needed to foster healthy child-caregiver relationships through Continuity of Care, Attachment Behaviors, Trauma Informed Caregiving, Caregiving Activities/Routines, Communication, and Shared Control.')
    highest = d_scores_clean.max
    highest_scoring_subdomain('4', d_scores, highest, 'Child-Caregiver Relationships')
    low_scoring_subdomains(lowest, d_scores, '4')
    red_flags('Domain 4: Child-Caregiver Relationships Red Flags')
  end

  def domain_five
    domain_title('Domain 5: Child Experience')
    domain_table('5')
    text 'The <b>Child Experience</b> domain measures the extent to which care at the center is focused on the best interests of the children in care. This domain considers Child Identity, Documentation Journals, Individually Assigned Materials, Supporting Child Development, Family-Like Setting, Lifeskills, Community Interactions, and Transitional Support. Ideally, every decision made, from the policy level to the caregiving level, is focused on providing optimal experiences for the children in care. This can be achieved by considering the best interest of the child in any given decision, rather than the best interest of the caregiver or center.', inline_format: true
    domain_score_graph('5', 'Domain 5: Child Experience Subdomain Feedback')
    d_scores = [
      @scores[@center.identifier]['5.1'], @scores[@center.identifier]['5.2'],
      @scores[@center.identifier]['5.3'], @scores[@center.identifier]['5.4'],
      @scores[@center.identifier]['5.5'], @scores[@center.identifier]['5.6'],
      @scores[@center.identifier]['5.7'], @scores[@center.identifier]['5.8']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, 'In your center, all domain 5 subdomains received scores higher than 3.01. This indicates that your center is meeting many of the requirements needed to provide children a supportive environment by considering factors related to Child Identity, Documentation Journals, Individually Assigned Materials, Supporting Child Development, Family-Like Setting, Lifeskills, Community Interactions, and Transitional Support.')
    highest = d_scores_clean.max
    highest_scoring_subdomain('5', d_scores, highest, 'Child Experience')
    low_scoring_subdomains(lowest, d_scores, '5')
    red_flags('Domain 5: Child Experience Red Flags')
  end

  def domain_six
    domain_title('Domain 6: Environment')
    domain_table('6')
    text "The <b>Environment</b> domain measures a center's ability to provide a safe and nurturing environment for children and staff. This domain considers Spaces, Materials, and Environmental Safety. Ideally, a center will contain multiple spaces that children and staff can enjoy safely for a variety of purposes, with access to a range of materials that can enhance a child's development.", inline_format: true
    domain_score_graph('6', 'Domain 6: Environment Subdomain Feedback')
    d_scores = [
      @scores[@center.identifier]['6.1'], @scores[@center.identifier]['6.2'],
      @scores[@center.identifier]['6.3']
    ]
    d_scores_clean = d_scores.reject { |e| e == '' }
    lowest = d_scores_clean.min
    doing_well(lowest, 'In your center, all domain 6 subdomains received scores higher than 3.01. This indicates that your center is meeting many of the requirements needed to provide a safe and supportive environment through Spaces, Materials, and Environmental Safety.')
    highest = d_scores_clean.max
    highest_scoring_subdomain('6', d_scores, highest, 'Environment')
    low_scoring_subdomains(lowest, d_scores, '6')
    red_flags('Domain 6: Environment Red Flags')
  end

  def domain_level_feedback
    domain_title('Domain-level Feedback')
  end

  def additional_feedback
    domain_title('Additional Feedback')
    text '[This section will contain more feedback from a Whole Child or ISNA representative who is knowledgeable about the center. The personalized feedback may contain additional notes about the center’s level of care and recommendations.]'
  end

  def comparison_chart
    domain_title('Score Comparison Chart')
    text 'Please refer to the chart below to compare your center’s scores to the average scores for public CDAs, private CDAs, and the national average for all CDAs.'
    move_down 10
    data = if is_cda?
             [
               ['', @center.name, 'CdAs Públicos', 'CdAs Privados', 'Ambos CdAs'],
               ['Puntuación central', @scores[@center.identifier]['Score'], @public_scores['Score'], @private_scores['Score'], @nat_avg_scores['Score']]
             ]
           else
             [
               ['', @center.name, "#{@center.center_type}s"],
               ['Puntuación central', @scores[@center.identifier]['Score'], @nat_avg_scores['Score']]
             ]
           end
    @score_scheme.domains.sort_by { |domain| domain.title.to_i }.each do |domain|
      ds = @scores[@center.identifier][domain.title]
      ds = ds.round(2) if ds != ''
      if is_cda?
        data << ["Domain #{domain.title}: #{domain.name}", '', '', '', '']
        data << ['Puntuación de dominio', ds, @public_scores[domain.title], @private_scores[domain.title], @nat_avg_scores[domain.title]]
      else
        data << ["Domain #{domain.title}: #{domain.name}", '', '']
        data << ['Puntuación de dominio', ds, @nat_avg_scores[domain.title]]
      end
      domain.subdomains.sort_by { |subdomain| subdomain.title.to_f }.each do |subdomain|
        next if subdomain.title == '1.5' || subdomain.title == '5.9'

        sds = @scores[@center.identifier][subdomain.title]
        sds = sds.round(2) if sds != ''
        data << if is_cda?
                  [full_sanitizer.sanitize(subdomain.translated_title_name('es')), sds, @public_scores[subdomain.title], @private_scores[subdomain.title], @nat_avg_scores[subdomain.title]]
                else
                  [full_sanitizer.sanitize(subdomain.translated_title_name('es')), sds, @nat_avg_scores[subdomain.title]]
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
    text 'Cells with no color indicate scores in the “high quality” range.'
    text 'Cells highlighted in <color rgb="FEC15D">orange</color> indicate scores in the “good quality” range.', inline_format: true
    text 'Cells highlighted in <color rgb="F06A78">red</color> indicate scores in the “low quality” range.', inline_format: true
  end
end
