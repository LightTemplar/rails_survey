# frozen_string_literal: true

object @score_unit

attributes :id, :weight, :score_type, :title, :subdomain_id, :base_point_score, :institution_type

node :domain_title, &:domain_title

node :subdomain_title, &:subdomain_title

node :question_identifiers, &:question_identifiers

node :domain_id, &:domain_id

child :option_scores do
  attributes :id, :score_unit_question_id, :value, :option_identifier, :follow_up_qid, :position
  node :question_identifier, &:question_identifier
end
