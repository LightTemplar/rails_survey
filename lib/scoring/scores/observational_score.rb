class ObservationalScore < Score
  def initialize(qid, survey_id, survey_uuid, device_label, device_user, center_id, raw_score, weight, domain, sub_domain)
    @qid = qid
    @survey_id = survey_id
    @survey_uuid = survey_uuid
    @device_label = device_label
    @device_user = device_user
    @center_id = center_id.to_i
    @raw_score = raw_score
    @weight = weight.to_i
    @domain = domain.to_i
    @sub_domain = sub_domain
  end
end
