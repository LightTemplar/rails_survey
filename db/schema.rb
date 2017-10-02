# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170915203407) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "android_updates", force: :cascade do |t|
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apk_update_file_name",    limit: 255
    t.string   "apk_update_content_type", limit: 255
    t.integer  "apk_update_file_size"
    t.datetime "apk_update_updated_at"
    t.string   "name",                    limit: 255
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_device_users", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "device_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_sync_entries", force: :cascade do |t|
    t.string   "latitude",               limit: 255
    t.string   "longitude",              limit: 255
    t.integer  "num_complete_surveys"
    t.string   "current_language",       limit: 255
    t.string   "current_version_code",   limit: 255
    t.text     "instrument_versions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "device_uuid",            limit: 255
    t.string   "api_key",                limit: 255
    t.string   "timezone",               limit: 255
    t.string   "current_version_name",   limit: 255
    t.string   "os_build_number",        limit: 255
    t.integer  "project_id"
    t.integer  "num_incomplete_surveys"
  end

  create_table "device_users", force: :cascade do |t|
    t.string   "username",        limit: 255,                 null: false
    t.string   "name",            limit: 255
    t.string   "password_digest", limit: 255
    t.boolean  "active",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: :cascade do |t|
    t.string   "identifier", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",      limit: 255
  end

  add_index "devices", ["identifier"], name: "index_devices_on_identifier", unique: true

  create_table "grid_label_translations", force: :cascade do |t|
    t.integer  "grid_label_id"
    t.integer  "instrument_translation_id"
    t.text     "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grid_labels", force: :cascade do |t|
    t.text     "label"
    t.integer  "grid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "position"
  end

  create_table "grid_translations", force: :cascade do |t|
    t.integer  "grid_id"
    t.integer  "instrument_translation_id"
    t.string   "name",                      limit: 255
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grids", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "question_type", limit: 255
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instructions"
    t.datetime "deleted_at"
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "question_id"
    t.string   "description",        limit: 255
    t.integer  "number"
    t.datetime "deleted_at"
  end

  add_index "images", ["deleted_at"], name: "index_images_on_deleted_at"

  create_table "instrument_translations", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "language",         limit: 255
    t.string   "alignment",        limit: 255
    t.string   "title",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "critical_message"
    t.boolean  "active",                       default: false
  end

  create_table "instruments", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",                limit: 255
    t.string   "alignment",               limit: 255
    t.integer  "child_update_count",                  default: 0
    t.integer  "previous_question_count"
    t.integer  "project_id"
    t.boolean  "published"
    t.datetime "deleted_at"
    t.boolean  "show_instructions",                   default: false
    t.text     "special_options"
    t.boolean  "show_sections_page",                  default: false
    t.boolean  "navigate_to_review_page",             default: false
    t.text     "critical_message"
    t.boolean  "roster",                              default: false
    t.string   "roster_type",             limit: 255
    t.boolean  "scorable",                            default: false
    t.boolean  "auto_export_responses",               default: true
  end

  create_table "metrics", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "name",          limit: 255
    t.integer  "expected"
    t.string   "key_name",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "option_scores", force: :cascade do |t|
    t.integer  "score_unit_id"
    t.integer  "option_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",         limit: 255
    t.boolean  "exists"
    t.boolean  "next_question"
    t.datetime "deleted_at"
  end

  add_index "option_scores", ["deleted_at"], name: "index_option_scores_on_deleted_at"

  create_table "option_translations", force: :cascade do |t|
    t.integer  "option_id"
    t.text     "text"
    t.string   "language",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "option_changed",                        default: false
    t.integer  "instrument_translation_id"
  end

  create_table "options", force: :cascade do |t|
    t.integer  "question_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "next_question",             limit: 255
    t.integer  "number_in_question"
    t.datetime "deleted_at"
    t.integer  "instrument_version_number",             default: -1
    t.boolean  "special",                               default: false
    t.boolean  "critical"
    t.boolean  "complete_survey"
  end

  create_table "project_device_users", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "device_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_devices", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_aggregator", limit: 255
  end

  create_table "question_randomized_factors", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "randomized_factor_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_translations", force: :cascade do |t|
    t.integer  "question_id"
    t.string   "language",                  limit: 255
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reg_ex_validation_message", limit: 255
    t.boolean  "question_changed",                      default: false
    t.text     "instructions"
    t.integer  "instrument_translation_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text     "text"
    t.string   "question_type",                    limit: 255
    t.string   "question_identifier",              limit: 255
    t.integer  "instrument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "following_up_question_identifier", limit: 255
    t.string   "reg_ex_validation",                limit: 255
    t.integer  "number_in_instrument"
    t.string   "reg_ex_validation_message",        limit: 255
    t.datetime "deleted_at"
    t.integer  "follow_up_position",                           default: 0
    t.boolean  "identifies_survey",                            default: false
    t.text     "instructions",                                 default: ""
    t.integer  "child_update_count",                           default: 0
    t.integer  "grid_id"
    t.integer  "instrument_version_number",                    default: -1
    t.integer  "section_id"
    t.boolean  "critical"
    t.integer  "number_in_grid"
  end

  add_index "questions", ["question_identifier"], name: "index_questions_on_question_identifier", unique: true

  create_table "randomized_factors", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "randomized_options", force: :cascade do |t|
    t.integer  "randomized_factor_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_scores", force: :cascade do |t|
    t.integer  "score_unit_id"
    t.integer  "score_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",          limit: 255
    t.string   "score_uuid",    limit: 255
  end

  create_table "response_exports", force: :cascade do |t|
    t.boolean  "long_done",                                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "instrument_id"
    t.text     "instrument_versions"
    t.boolean  "wide_done",                                   default: false
    t.boolean  "short_done",                                  default: false
    t.decimal  "completion",          precision: 5, scale: 2, default: 0.0
  end

  create_table "response_images", force: :cascade do |t|
    t.string   "response_uuid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "response_images_exports", force: :cascade do |t|
    t.integer  "response_export_id"
    t.string   "download_url",       limit: 255
    t.boolean  "done",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "responses", force: :cascade do |t|
    t.integer  "question_id"
    t.text     "text"
    t.text     "other_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_uuid",         limit: 255
    t.string   "special_response",    limit: 255
    t.datetime "time_started"
    t.datetime "time_ended"
    t.string   "question_identifier", limit: 255
    t.string   "uuid",                limit: 255
    t.integer  "device_user_id"
    t.integer  "question_version",                default: -1
    t.datetime "deleted_at"
    t.text     "randomized_data"
  end

  add_index "responses", ["deleted_at"], name: "index_responses_on_deleted_at"
  add_index "responses", ["survey_uuid"], name: "index_responses_on_survey_uuid"
  add_index "responses", ["time_ended"], name: "index_responses_on_time_ended"
  add_index "responses", ["time_started"], name: "index_responses_on_time_started"
  add_index "responses", ["uuid"], name: "index_responses_on_uuid"

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rosters", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "uuid",                      limit: 255
    t.integer  "instrument_id"
    t.string   "identifier",                limit: 255
    t.string   "instrument_title",          limit: 255
    t.integer  "instrument_version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", force: :cascade do |t|
    t.string   "rule_type",     limit: 255
    t.integer  "instrument_id"
    t.string   "rule_params",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "deleted_at"
  end

  create_table "score_schemes", force: :cascade do |t|
    t.integer  "instrument_id", limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "score_schemes", ["deleted_at"], name: "index_score_schemes_on_deleted_at"

  create_table "score_sections", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instrument_id"
  end

  create_table "score_sub_sections", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "score_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "score_unit_questions", force: :cascade do |t|
    t.integer  "score_unit_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "score_unit_questions", ["deleted_at"], name: "index_score_unit_questions_on_deleted_at"

  create_table "score_units", force: :cascade do |t|
    t.integer  "score_scheme_id"
    t.string   "question_type",   limit: 255
    t.float    "min"
    t.float    "max"
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score_type"
    t.datetime "deleted_at"
  end

  add_index "score_units", ["deleted_at"], name: "index_score_units_on_deleted_at"

  create_table "scores", force: :cascade do |t|
    t.integer  "survey_id"
    t.integer  "score_scheme_id"
    t.float    "score_sum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",            limit: 255
    t.string   "survey_uuid",     limit: 255
    t.string   "device_uuid",     limit: 255
    t.string   "device_label",    limit: 255
  end

  create_table "section_translations", force: :cascade do |t|
    t.integer  "section_id"
    t.string   "language",                  limit: 255
    t.string   "text",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "section_changed",                       default: false
    t.integer  "instrument_translation_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instrument_id"
    t.datetime "deleted_at"
  end

  add_index "sections", ["deleted_at"], name: "index_sections_on_deleted_at"

  create_table "skips", force: :cascade do |t|
    t.integer  "option_id"
    t.string   "question_identifier", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "skips", ["deleted_at"], name: "index_skips_on_deleted_at"

  create_table "stats", force: :cascade do |t|
    t.integer  "metric_id"
    t.string   "key_value",  limit: 255
    t.integer  "count"
    t.string   "percent",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_scores", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_id"
    t.string   "survey_uuid",       limit: 255
    t.string   "device_label",      limit: 255
    t.string   "device_user",       limit: 255
    t.string   "survey_start_time", limit: 255
    t.string   "survey_end_time",   limit: 255
    t.string   "center_id",         limit: 255
  end

  create_table "surveys", force: :cascade do |t|
    t.integer  "instrument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",                      limit: 255
    t.integer  "device_id"
    t.integer  "instrument_version_number"
    t.string   "instrument_title",          limit: 255
    t.string   "device_uuid",               limit: 255
    t.string   "latitude",                  limit: 255
    t.string   "longitude",                 limit: 255
    t.text     "metadata"
    t.string   "completion_rate",           limit: 3
    t.string   "device_label",              limit: 255
    t.datetime "deleted_at"
    t.boolean  "has_critical_responses"
    t.string   "roster_uuid",               limit: 255
    t.string   "language",                  limit: 255
  end

  add_index "surveys", ["deleted_at"], name: "index_surveys_on_deleted_at"
  add_index "surveys", ["uuid"], name: "index_surveys_on_uuid"

  create_table "unit_scores", force: :cascade do |t|
    t.integer  "survey_score_id"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value"
    t.integer  "variable_id"
    t.string   "center_section_sub_section_name", limit: 255
    t.string   "center_section_name",             limit: 255
  end

  create_table "units", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weight"
    t.integer  "score_sub_section_id"
    t.string   "domain",               limit: 255
    t.string   "sub_domain",           limit: 255
  end

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",  null: false
    t.string   "encrypted_password",     limit: 255, default: "",  null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "authentication_token",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "failed_attempts",                    default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "last_active_at"
    t.string   "gauth_secret",           limit: 255
    t.string   "gauth_enabled",          limit: 255, default: "f"
    t.string   "gauth_tmp",              limit: 255
    t.datetime "gauth_tmp_datetime"
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type",        limit: 255
    t.integer  "invitations_count",                  default: 0
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count"
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "variables", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "value"
    t.string   "next_variable",  limit: 255
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result",         limit: 255
    t.string   "next_unit_name", limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
