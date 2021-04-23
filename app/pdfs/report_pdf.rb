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
  end

  def page_one
    text "<font size='14'><b>#{@center.name}</b></font>", inline_format: true, align: :right
    date = DateTime.now
    text "<font size='14'><b>#{date.strftime('%B %Y')}</b></font>", inline_format: true, align: :right
    font('Avenir Next Condensed') do
      text "<font size='36'><b>NATIONAL EVALUATION ON THE</b></font>", inline_format: true, color: '2F642F', align: :right
      text "<font size='36'><b>QUALITY OF CARE</b></font>", inline_format: true, color: '2F642F', align: :right
    end
    move_down 10
    image "#{Rails.root}/app/pdfs/images/holding_hands.jpg", width: 400, height: 250, position: :center
    move_down 100
    image "#{Rails.root}/app/pdfs/images/sponsors.png", width: 400, position: :center
  end

  def page_two
    font('Avenir Next Condensed') do
      text "<font size='36'><b>2020 NATIONAL EVALUATION ON </b></font>", inline_format: true, color: '2F642F', align: :left
      text "<font size='36'><b>THE QUALITY OF CARE: El Salvador</b></font>", inline_format: true, color: '2F642F', align: :left
    end
    text "Thank you for participating in the 2020 National Evaluation on the Quality of Care. This effort was carried out as a way to measure the quality of care being provided to boys, girls, and adolescents in residential and non-residential centers throughout El Salvador."
    move_down 10
    text "In partnership with Duke University, CONNA, and ISNA, Whole Child International created a comprehensive tool to measure care under 6 domains: <b>administration and governance; basic needs; child protection; child-caregiver relationships; child experience; and environment.</b> With this report, we hope to provide guidance on ways to improve the quality of care given to children around the country.", inline_format: true
    move_down 10
    text "This report contains center-specific scores and recommendations. Our goal is to provide each center with the opportunity to review the areas in which they might already be excelling and which require more attention. We hope this is a useful tool as you consider how to best serve the children under your care."
    move_down 10
    text "Please remember that any low scores should be interpreted as opportunities for improvement and that we will work together to strategize next steps and goals for your center. Also keep in mind that high scores may still require maintenance and we will work with you to help in that area as well."
    move_down 10
    text "Once again, thank you for taking part in the efforts to learn about the quality of care provided to the children in El Salvador. We will be reaching out to you soon to discuss your center's scores in more detail."
  end

  def page_three
    font('Avenir Next Condensed') do
      text "<font size='36'><b>How to use this report</b></font>", inline_format: true, color: '2F642F'
    end
    text "This report will provide you with feedback on areas that your center is already providing good or high-quality care as well as those that may benefit from additional attention."
    move_down 10
    text 'The “Center Report” page contains an overview of some basic information about your center, including the center’s name, director, person who completed the interview, the date data collection was completed, and whether both elements of this process – the interview and observation – were completed. This page also contains a chart that will allow you to quickly compare your center’s scores to the national averages.'
    move_down 10
    text "The report then provides feedback by domain. Each domain and subdomain receives a score of 1 to 7, with scores of 1-3 indicating <b>low quality care</b>, scores of 3.01-5 indicating <b>good care</b>, and scores of 5.01-7 indicating <b>high-quality care</b>. These scores were obtained through a combination of interviews with center leaders and an observation carried out by a trained data collector. You will see your center’s domain-level score, the national average, and a description of the factors that were considered under each domain (which we refer to as subdomains).", inline_format: true
    move_down 10
    text "You will receive scores for every subdomain and feedback for the area your center is providing the highest level of care. Additionally, centers that had <b>low</b> scores in a subdomain will receive additional feedback on that specific topic. This feedback provides a brief definition of the subdomain, an explanation of its importance, and basic recommendations on how to improve care in this area.", inline_format: true
    move_down 10
    text 'This report also provides you with feedback on “red flags” that arose on specific questions that were answered or items that our enumerators observed during their visits that are fundamental to high-quality care. They are flagged here to ensure that your center is aware of any potentially significant issues and to help guide conversations about improvements to your center. These issues should be addressed to the best of your ability to increase the level of care your center is providing. You will see a summary of the question and answer or observation note that triggered a “red flag”. We provide a brief explanation on why a particular “red flag” is important followed by recommendations on ways to address it.'
    move_down 10
    text "Please note that you may not receive red flag feedback under every domain."
    move_down 10
    text "Every center will receive domain-level recommendations based on score. These domain-level recommendations are located in the final section of the report. The recommendations focus primarily on the most important aspects of care. Not all potential methods of improvement are included. Further specific recommendations and strategies to improve care in your center can be discussed in collaboration with your ISNA representative. Feel free to use the checkboxes to mark which points you would like to focus on in your discussions."
    move_down 10
    text "We recommend that you thoroughly review the recommendations below to identify potential areas for improvement. Some recommendations touch on areas that may not be under your immediate control. We encourage you to consult with ISNA, Whole Child, or other organizations, as appropriate, with any questions and to find ways to best support your ongoing efforts to serve the children of El Salvador."
  end

  def center_report
    font('Avenir Next Condensed') do
      text "<font size='36'><b>Center Report</b></font>", inline_format: true, color: '2F642F'
    end
    css = @center.survey_scores.where(score_scheme_id: @score_scheme.id)
    contact = @center.contact(css)
    formatted_text [{ text: 'Center: ', styles: [:bold], color: '2F642F' }, { text: @center.name }]
    move_down 10
    formatted_text [{ text: 'Director: ', styles: [:bold], color: '2F642F' }, { text: contact }]
    move_down 10
    formatted_text [{ text: 'Center Representative/Interviewee: ', styles: [:bold], color: '2F642F' }, { text: contact }]
    move_down 10
    formatted_text [{ text: 'Data Collection Completed: ', styles: [:bold], color: '2F642F' }, { text: @center.interview_date(css) }]
    move_down 10
    formatted_text [{ text: 'Interview: ', styles: [:bold], color: '2F642F' }, { text: @center.interview?(css, @score_scheme) },
                    { text: ' Observation: ', styles: [:bold], color: '2F642F' }, { text: @center.observation?(css, @score_scheme) }
                   ]
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

    font('Avenir Next Condensed') do
      text "<font size='20'><b>Center Snapshot</b></font>", inline_format: true, color: '2F642F'
    end
    image "#{Rails.root}/files/reports/#{@center.identifier}-0.png", width: 400, height: 250, position: :center
    text "<font size='10'>*National average is among CDAs only.</font>", inline_format: true
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
  end

  def domain_one
    font('Avenir Next Condensed') do
      text "<font size='20'><b>Domain 1: Administration & Governance</b></font>", inline_format: true, color: '2F642F'
    end
    move_down 10
    table [
            ["", "<b>Center Name</b>", "<b>#{@center.center_type}s</b>"],
            ["<b>Puntuación de Dominio</b>", @center.name, @nat_avg_scores["1"]]
          ], position: :center, cell_style: { inline_format: true }
    move_down 10
    text "The <b>Administration & Governance</b> domain measures the way in which a childcare center is managed at the administrative level. This domain considers Oversight & Leadership, Professional Practices, Caregiver Well-being, and Staff Training & Development. Ideally, leadership is able to use the resources they have to create and maintain a healthy organizational culture, which in turn affects the quality of care provided within a childcare center.", inline_format: true
    move_down 10
    text "Your center received a score of <b>#{@scores[@center.identifier]['1']}</b> for this domain. This score is in the <b>XXth</b> percentile. Please see the section below titled “Domain-level Feedback” for more details on how to maintain or improve care in this domain.", inline_format: true
    move_down 20
    font('Avenir Next Condensed') do
      text "<font size='16'><b>Domain 1: Administration & Governance Subdomain Feedback</b></font>", inline_format: true, color: '767171'
    end
    move_down 10
    image "#{Rails.root}/files/reports/#{@center.identifier}-1.png", width: 400, height: 250, position: :center
    move_down 10
    d1_scores = [
                  @scores[@center.identifier]['1.1'], @scores[@center.identifier]['1.2'],
                  @scores[@center.identifier]['1.3'], @scores[@center.identifier]['1.4']
                ]
    lowest = d1_scores.min
    if lowest >= 3.01
      text "In your center, all domain 1 subdomains received scores higher than 3.01. This indicates that your center is meeting many of the requirements needed to provide good support for Oversight & Leadership, Professional Practices, Caregiver Well-being, and Staff Training & Development."
      move_down 10
    end
    highest = d1_scores.max
    sd_title = "1.#{d1_scores.index(highest) + 1}"
    sd = @score_scheme.subdomains.find_by(title: sd_title)
    text "Your center’s highest scoring subdomain under Administration & Governance was <b>#{sd_title}</b>, with a score of <b>#{highest}</b>. [#{sd.name} – high score]", inline_format: true
    if lowest < 3.01
      move_down 10
      text "Within this domain, this center is providing <b>low quality</b> care in the following subdomains, and improvement is necessary.", inline_format: true
      move_down 10
      d1_scores.each_with_index do |score, index|
        if score < 3.01
          sd_title = "1.#{index + 1}"
          sd = @score_scheme.subdomains.find_by(title: sd_title)
          text "Your center scored <b>#{score}</b> in the <b>#{sd_title}</b> subdomain. [#{sd.name} – low score]", inline_format: true
        end
      end
    end
  end

end
