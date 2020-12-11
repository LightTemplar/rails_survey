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

ActiveRecord::Schema.define(version: 20201208185338) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "android_updates", force: :cascade do |t|
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apk_update_file_name"
    t.string   "apk_update_content_type"
    t.integer  "apk_update_file_size"
    t.datetime "apk_update_updated_at"
    t.string   "name"
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "device_user_id"
  end

  create_table "ar_internal_metadata", primary_key: "key", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "back_translations", force: :cascade do |t|
    t.text     "text"
    t.string   "language"
    t.integer  "backtranslatable_id"
    t.string   "backtranslatable_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.boolean  "approved"
  end

  add_index "back_translations", ["backtranslatable_id", "backtranslatable_type", "language"], name: "backtranslatable_index", unique: true, using: :btree

  create_table "condition_skips", force: :cascade do |t|
    t.integer  "instrument_question_id"
    t.string   "question_identifier"
    t.string   "condition_question_identifier"
    t.string   "condition_option_identifier"
    t.string   "option_identifier"
    t.string   "condition"
    t.string   "next_question_identifier"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "condition_skips", ["instrument_question_id"], name: "index_condition_skips_on_instrument_question_id", using: :btree

  create_table "critical_responses", force: :cascade do |t|
    t.string   "question_identifier"
    t.string   "option_identifier"
    t.integer  "instruction_id"
    t.datetime "deleted_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "critical_responses", ["instruction_id"], name: "index_critical_responses_on_instruction_id", using: :btree
  add_index "critical_responses", ["option_identifier"], name: "index_critical_responses_on_option_identifier", using: :btree
  add_index "critical_responses", ["question_identifier"], name: "index_critical_responses_on_question_identifier", using: :btree

  create_table "device_device_users", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "device_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_sync_entries", force: :cascade do |t|
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "num_complete_surveys"
    t.string   "current_language"
    t.string   "current_version_code"
    t.text     "instrument_versions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "device_uuid"
    t.string   "api_key"
    t.string   "timezone"
    t.string   "current_version_name"
    t.string   "os_build_number"
    t.integer  "project_id"
    t.integer  "num_incomplete_surveys"
    t.string   "device_label"
  end

  create_table "device_users", force: :cascade do |t|
    t.string   "username",                        null: false
    t.string   "name"
    t.string   "password_digest"
    t.boolean  "active",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_users", ["username"], name: "index_device_users_on_username", using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label"
  end

  add_index "devices", ["identifier"], name: "index_devices_on_identifier", unique: true, using: :btree

  create_table "display_instructions", force: :cascade do |t|
    t.integer  "display_id"
    t.integer  "instruction_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "instrument_question_id"
  end

  add_index "display_instructions", ["display_id"], name: "index_display_instructions_on_display_id", using: :btree
  add_index "display_instructions", ["instruction_id"], name: "index_display_instructions_on_instruction_id", using: :btree
  add_index "display_instructions", ["instrument_question_id"], name: "index_display_instructions_on_instrument_question_id", using: :btree

  create_table "display_translations", force: :cascade do |t|
    t.integer  "display_id"
    t.text     "text"
    t.string   "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "display_translations", ["display_id"], name: "index_display_translations_on_display_id", using: :btree
  add_index "display_translations", ["language"], name: "index_display_translations_on_language", using: :btree

  create_table "displays", force: :cascade do |t|
    t.integer  "position"
    t.integer  "instrument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.datetime "deleted_at"
    t.integer  "section_id"
    t.integer  "instrument_questions_count"
    t.integer  "instrument_position"
  end

  add_index "displays", ["deleted_at"], name: "index_displays_on_deleted_at", using: :btree
  add_index "displays", ["instrument_id"], name: "index_displays_on_instrument_id", using: :btree
  add_index "displays", ["position"], name: "index_displays_on_position", using: :btree
  add_index "displays", ["section_id"], name: "index_displays_on_section_id", using: :btree

  create_table "domains", force: :cascade do |t|
    t.string   "title"
    t.integer  "score_scheme_id"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "domains", ["deleted_at"], name: "index_domains_on_deleted_at", using: :btree
  add_index "domains", ["score_scheme_id"], name: "index_domains_on_score_scheme_id", using: :btree

  create_table "folders", force: :cascade do |t|
    t.integer  "question_set_id"
    t.string   "title"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "position"
  end

  add_index "folders", ["position"], name: "index_folders_on_position", using: :btree
  add_index "folders", ["question_set_id"], name: "index_folders_on_question_set_id", using: :btree

  create_table "follow_up_questions", force: :cascade do |t|
    t.string   "question_identifier"
    t.string   "following_up_question_identifier"
    t.integer  "position"
    t.integer  "instrument_question_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "follow_up_questions", ["instrument_question_id"], name: "index_follow_up_questions_on_instrument_question_id", using: :btree

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
    t.string   "name"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grids", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "question_type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instructions"
    t.datetime "deleted_at"
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "question_id"
    t.string   "description"
    t.integer  "number"
    t.datetime "deleted_at"
  end

  add_index "images", ["deleted_at"], name: "index_images_on_deleted_at", using: :btree
  add_index "images", ["question_id"], name: "index_images_on_question_id", using: :btree

  create_table "instruction_translations", force: :cascade do |t|
    t.integer  "instruction_id"
    t.string   "language"
    t.text     "text"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "instruction_translations", ["instruction_id"], name: "index_instruction_translations_on_instruction_id", using: :btree
  add_index "instruction_translations", ["language"], name: "index_instruction_translations_on_language", using: :btree

  create_table "instructions", force: :cascade do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "instructions", ["deleted_at"], name: "index_instructions_on_deleted_at", using: :btree
  add_index "instructions", ["title"], name: "index_instructions_on_title", using: :btree

  create_table "instrument_questions", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "instrument_id"
    t.integer  "number_in_instrument"
    t.integer  "display_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.datetime "deleted_at"
    t.string   "table_identifier"
    t.integer  "loop_questions_count",     default: 0
    t.string   "carry_forward_identifier"
    t.integer  "position"
    t.string   "skip_operation"
  end

  add_index "instrument_questions", ["deleted_at"], name: "index_instrument_questions_on_deleted_at", using: :btree
  add_index "instrument_questions", ["display_id"], name: "index_instrument_questions_on_display_id", using: :btree
  add_index "instrument_questions", ["instrument_id", "identifier"], name: "index_instrument_questions_on_instrument_id_and_identifier", using: :btree
  add_index "instrument_questions", ["instrument_id"], name: "index_instrument_questions_on_instrument_id", using: :btree
  add_index "instrument_questions", ["number_in_instrument"], name: "index_instrument_questions_on_number_in_instrument", using: :btree
  add_index "instrument_questions", ["position"], name: "index_instrument_questions_on_position", using: :btree
  add_index "instrument_questions", ["question_id"], name: "index_instrument_questions_on_question_id", using: :btree

  create_table "instrument_rules", force: :cascade do |t|
    t.integer  "instrument_id"
    t.integer  "rule_id"
    t.datetime "deleted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "instrument_rules", ["instrument_id"], name: "index_instrument_rules_on_instrument_id", using: :btree
  add_index "instrument_rules", ["rule_id"], name: "index_instrument_rules_on_rule_id", using: :btree

  create_table "instrument_translations", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "language"
    t.string   "alignment"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",        default: false
  end

  add_index "instrument_translations", ["instrument_id"], name: "index_instrument_translations_on_instrument_id", using: :btree
  add_index "instrument_translations", ["language"], name: "index_instrument_translations_on_language", using: :btree

  create_table "instruments", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language"
    t.string   "alignment"
    t.integer  "instrument_questions_count", default: 0
    t.integer  "project_id"
    t.boolean  "published"
    t.datetime "deleted_at"
    t.boolean  "require_responses",          default: false
    t.boolean  "scorable",                   default: false
    t.boolean  "auto_export_responses",      default: true
  end

  add_index "instruments", ["project_id", "title"], name: "index_instruments_on_project_id_and_title", using: :btree
  add_index "instruments", ["project_id"], name: "index_instruments_on_project_id", using: :btree

  create_table "loop_questions", force: :cascade do |t|
    t.integer  "instrument_question_id"
    t.string   "parent"
    t.string   "looped"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "deleted_at"
    t.string   "option_indices"
    t.boolean  "same_display",           default: false
    t.text     "replacement_text"
  end

  add_index "loop_questions", ["instrument_question_id"], name: "index_loop_questions_on_instrument_question_id", using: :btree

  create_table "metrics", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "name"
    t.integer  "expected"
    t.string   "key_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "multiple_skips", force: :cascade do |t|
    t.string   "question_identifier"
    t.string   "option_identifier"
    t.string   "skip_question_identifier"
    t.integer  "instrument_question_id"
    t.datetime "deleted_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "value"
  end

  add_index "multiple_skips", ["instrument_question_id"], name: "index_multiple_skips_on_instrument_question_id", using: :btree
  add_index "multiple_skips", ["option_identifier"], name: "index_multiple_skips_on_option_identifier", using: :btree

  create_table "next_questions", force: :cascade do |t|
    t.string   "question_identifier"
    t.string   "option_identifier"
    t.string   "next_question_identifier"
    t.integer  "instrument_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "value"
    t.boolean  "complete_survey"
    t.string   "value_operator"
  end

  add_index "next_questions", ["instrument_question_id"], name: "index_next_questions_on_instrument_question_id", using: :btree
  add_index "next_questions", ["option_identifier"], name: "index_next_questions_on_option_identifier", using: :btree

  create_table "option_in_option_sets", force: :cascade do |t|
    t.integer  "option_id",                          null: false
    t.integer  "option_set_id",                      null: false
    t.integer  "number_in_question",                 null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "special",            default: false
    t.integer  "instruction_id"
    t.boolean  "allow_text_entry",   default: false
    t.text     "exclusion_ids"
  end

  add_index "option_in_option_sets", ["instruction_id"], name: "index_option_in_option_sets_on_instruction_id", using: :btree
  add_index "option_in_option_sets", ["number_in_question"], name: "index_option_in_option_sets_on_number_in_question", using: :btree
  add_index "option_in_option_sets", ["option_id"], name: "index_option_in_option_sets_on_option_id", using: :btree
  add_index "option_in_option_sets", ["option_set_id"], name: "index_option_in_option_sets_on_option_set_id", using: :btree

  create_table "option_scores", force: :cascade do |t|
    t.integer  "score_unit_question_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "option_identifier"
    t.string   "follow_up_qid"
    t.string   "position"
  end

  add_index "option_scores", ["deleted_at"], name: "index_option_scores_on_deleted_at", using: :btree
  add_index "option_scores", ["score_unit_question_id"], name: "index_option_scores_on_score_unit_question_id", using: :btree

  create_table "option_set_translations", force: :cascade do |t|
    t.integer  "option_set_id"
    t.integer  "option_translation_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "option_set_translations", ["option_set_id"], name: "index_option_set_translations_on_option_set_id", using: :btree
  add_index "option_set_translations", ["option_translation_id"], name: "index_option_set_translations_on_option_translation_id", using: :btree

  create_table "option_sets", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "special",                     default: false
    t.datetime "deleted_at"
    t.integer  "instruction_id"
    t.integer  "option_in_option_sets_count", default: 0
  end

  add_index "option_sets", ["instruction_id"], name: "index_option_sets_on_instruction_id", using: :btree
  add_index "option_sets", ["title"], name: "index_option_sets_on_title", unique: true, using: :btree

  create_table "option_translations", force: :cascade do |t|
    t.integer  "option_id"
    t.text     "text"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "option_changed",            default: false
    t.integer  "instrument_translation_id"
  end

  add_index "option_translations", ["language"], name: "index_option_translations_on_language", using: :btree
  add_index "option_translations", ["option_id"], name: "index_option_translations_on_option_id", using: :btree

  create_table "options", force: :cascade do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "instrument_version_number", default: -1
    t.string   "identifier"
  end

  add_index "options", ["identifier"], name: "index_options_on_identifier", using: :btree

  create_table "project_device_users", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "device_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_device_users", ["device_user_id"], name: "index_project_device_users_on_device_user_id", using: :btree
  add_index "project_device_users", ["project_id"], name: "index_project_device_users_on_project_id", using: :btree

  create_table "project_devices", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_aggregator"
  end

  create_table "question_randomized_factors", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "randomized_factor_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_randomized_factors", ["question_id"], name: "index_question_randomized_factors_on_question_id", using: :btree
  add_index "question_randomized_factors", ["randomized_factor_id"], name: "index_question_randomized_factors_on_randomized_factor_id", using: :btree

  create_table "question_sets", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_sets", ["title"], name: "index_question_sets_on_title", using: :btree

  create_table "question_translations", force: :cascade do |t|
    t.integer  "question_id"
    t.string   "language"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reg_ex_validation_message"
    t.boolean  "question_changed",          default: false
    t.text     "instructions"
    t.integer  "instrument_translation_id"
  end

  add_index "question_translations", ["language"], name: "index_question_translations_on_language", using: :btree
  add_index "question_translations", ["question_id"], name: "index_question_translations_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "text"
    t.string   "question_type"
    t.string   "question_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "identifies_survey",         default: false
    t.integer  "question_set_id"
    t.integer  "option_set_id"
    t.integer  "instruction_id"
    t.integer  "special_option_set_id"
    t.string   "parent_identifier"
    t.integer  "folder_id"
    t.integer  "validation_id"
    t.boolean  "rank_responses",            default: false
    t.integer  "versions_count",            default: 0
    t.integer  "images_count",              default: 0
    t.integer  "pdf_response_height"
    t.boolean  "pdf_print_options",         default: true
    t.text     "default_response"
    t.integer  "position"
    t.integer  "pop_up_instruction_id"
    t.integer  "after_text_instruction_id"
  end

  add_index "questions", ["after_text_instruction_id"], name: "index_questions_on_after_text_instruction_id", using: :btree
  add_index "questions", ["instruction_id"], name: "index_questions_on_instruction_id", using: :btree
  add_index "questions", ["option_set_id"], name: "index_questions_on_option_set_id", using: :btree
  add_index "questions", ["pop_up_instruction_id"], name: "index_questions_on_pop_up_instruction_id", using: :btree
  add_index "questions", ["position"], name: "index_questions_on_position", using: :btree
  add_index "questions", ["question_identifier"], name: "index_questions_on_question_identifier", unique: true, using: :btree
  add_index "questions", ["question_set_id"], name: "index_questions_on_question_set_id", using: :btree
  add_index "questions", ["special_option_set_id"], name: "index_questions_on_special_option_set_id", using: :btree
  add_index "questions", ["validation_id"], name: "index_questions_on_validation_id", using: :btree

  create_table "randomized_factors", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "randomized_factors", ["instrument_id"], name: "index_randomized_factors_on_instrument_id", using: :btree

  create_table "randomized_option_translations", force: :cascade do |t|
    t.integer  "instrument_translation_id"
    t.integer  "randomized_option_id"
    t.text     "text"
    t.string   "language"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "randomized_options", force: :cascade do |t|
    t.integer  "randomized_factor_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "randomized_options", ["randomized_factor_id"], name: "index_randomized_options_on_randomized_factor_id", using: :btree

  create_table "raw_scores", force: :cascade do |t|
    t.integer  "score_unit_id"
    t.integer  "survey_score_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.string   "survey_score_uuid"
    t.datetime "deleted_at"
  end

  create_table "response_exports", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instrument_id"
    t.text     "instrument_versions"
    t.decimal  "completion",          precision: 5, scale: 2, default: 0.0
  end

  create_table "response_images", force: :cascade do |t|
    t.string   "response_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "response_images_exports", force: :cascade do |t|
    t.integer  "response_export_id"
    t.string   "download_url"
    t.boolean  "done",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "responses", force: :cascade do |t|
    t.integer  "question_id"
    t.text     "text"
    t.text     "other_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_uuid"
    t.string   "special_response"
    t.datetime "time_started"
    t.datetime "time_ended"
    t.string   "question_identifier"
    t.string   "uuid"
    t.integer  "device_user_id"
    t.integer  "question_version",    default: -1
    t.datetime "deleted_at"
    t.text     "randomized_data"
    t.string   "rank_order"
    t.text     "other_text"
  end

  add_index "responses", ["deleted_at"], name: "index_responses_on_deleted_at", using: :btree
  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["question_identifier"], name: "index_responses_on_question_identifier", using: :btree
  add_index "responses", ["survey_uuid"], name: "index_responses_on_survey_uuid", using: :btree
  add_index "responses", ["time_ended"], name: "index_responses_on_time_ended", using: :btree
  add_index "responses", ["time_started"], name: "index_responses_on_time_started", using: :btree
  add_index "responses", ["uuid"], name: "index_responses_on_uuid", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rosters", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "uuid"
    t.integer  "instrument_id"
    t.string   "identifier"
    t.string   "instrument_title"
    t.integer  "instrument_version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", force: :cascade do |t|
    t.string   "rule_type"
    t.string   "rule_params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "deleted_at"
  end

  create_table "score_schemes", force: :cascade do |t|
    t.integer  "instrument_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "active"
  end

  add_index "score_schemes", ["deleted_at"], name: "index_score_schemes_on_deleted_at", using: :btree
  add_index "score_schemes", ["instrument_id"], name: "index_score_schemes_on_instrument_id", using: :btree

  create_table "score_unit_questions", force: :cascade do |t|
    t.integer  "score_unit_id"
    t.integer  "instrument_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "score_unit_questions", ["deleted_at"], name: "index_score_unit_questions_on_deleted_at", using: :btree
  add_index "score_unit_questions", ["instrument_question_id"], name: "index_score_unit_questions_on_instrument_question_id", using: :btree
  add_index "score_unit_questions", ["score_unit_id"], name: "index_score_unit_questions_on_score_unit_id", using: :btree

  create_table "score_units", force: :cascade do |t|
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "score_type"
    t.datetime "deleted_at"
    t.integer  "subdomain_id"
    t.string   "title"
  end

  add_index "score_units", ["deleted_at"], name: "index_score_units_on_deleted_at", using: :btree
  add_index "score_units", ["subdomain_id"], name: "index_score_units_on_subdomain_id", using: :btree

  create_table "section_translations", force: :cascade do |t|
    t.integer  "section_id"
    t.string   "language"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "section_changed",           default: false
    t.integer  "instrument_translation_id"
  end

  add_index "section_translations", ["language"], name: "index_section_translations_on_language", using: :btree
  add_index "section_translations", ["section_id"], name: "index_section_translations_on_section_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instrument_id"
    t.datetime "deleted_at"
    t.integer  "position"
  end

  add_index "sections", ["deleted_at"], name: "index_sections_on_deleted_at", using: :btree
  add_index "sections", ["instrument_id", "title"], name: "index_sections_on_instrument_id_and_title", using: :btree
  add_index "sections", ["instrument_id"], name: "index_sections_on_instrument_id", using: :btree
  add_index "sections", ["position"], name: "index_sections_on_position", using: :btree

  create_table "skip_patterns", force: :cascade do |t|
    t.string   "option_identifier"
    t.string   "question_identifier"
    t.string   "next_question_identifier"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "skips", force: :cascade do |t|
    t.integer  "option_id"
    t.string   "question_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "skips", ["deleted_at"], name: "index_skips_on_deleted_at", using: :btree

  create_table "stats", force: :cascade do |t|
    t.integer  "metric_id"
    t.string   "key_value"
    t.integer  "count"
    t.string   "percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subdomains", force: :cascade do |t|
    t.string   "title"
    t.integer  "domain_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subdomains", ["deleted_at"], name: "index_subdomains_on_deleted_at", using: :btree
  add_index "subdomains", ["domain_id"], name: "index_subdomains_on_domain_id", using: :btree

  create_table "survey_exports", force: :cascade do |t|
    t.integer  "survey_id"
    t.text     "long"
    t.text     "short"
    t.text     "wide"
    t.datetime "last_response_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "survey_exports", ["survey_id"], name: "index_survey_exports_on_survey_id", using: :btree

  create_table "survey_notes", id: :bigserial, force: :cascade do |t|
    t.string   "uuid"
    t.string   "survey_uuid"
    t.integer  "device_user_id"
    t.string   "reference"
    t.text     "text"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "survey_notes", ["survey_uuid"], name: "index_survey_notes_on_survey_uuid", using: :btree
  add_index "survey_notes", ["uuid"], name: "index_survey_notes_on_uuid", using: :btree

  create_table "survey_scores", force: :cascade do |t|
    t.integer  "survey_id"
    t.integer  "score_scheme_id"
    t.float    "score_sum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.string   "survey_uuid"
    t.string   "device_uuid"
    t.string   "device_label"
    t.datetime "deleted_at"
  end

  create_table "surveys", force: :cascade do |t|
    t.integer  "instrument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.integer  "device_id"
    t.integer  "instrument_version_number"
    t.string   "instrument_title"
    t.string   "device_uuid"
    t.string   "latitude"
    t.string   "longitude"
    t.text     "metadata"
    t.string   "completion_rate"
    t.string   "device_label"
    t.datetime "deleted_at"
    t.string   "language"
    t.text     "skipped_questions"
    t.integer  "completed_responses_count"
  end

  add_index "surveys", ["deleted_at"], name: "index_surveys_on_deleted_at", using: :btree
  add_index "surveys", ["instrument_id"], name: "index_surveys_on_instrument_id", using: :btree
  add_index "surveys", ["uuid"], name: "index_surveys_on_uuid", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_projects", ["project_id"], name: "index_user_projects_on_project_id", using: :btree
  add_index "user_projects", ["user_id"], name: "index_user_projects_on_user_id", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.datetime "gauth_tmp_datetime"
    t.string   "gauth_tmp"
    t.string   "gauth_enabled"
    t.string   "gauth_secret"
    t.string   "password_digest"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "validation_translations", force: :cascade do |t|
    t.integer  "validation_id"
    t.string   "language"
    t.string   "text"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "validation_translations", ["language"], name: "index_validation_translations_on_language", using: :btree
  add_index "validation_translations", ["validation_id"], name: "index_validation_translations_on_validation_id", using: :btree

  create_table "validations", force: :cascade do |t|
    t.string   "title"
    t.string   "validation_text"
    t.string   "validation_message"
    t.datetime "deleted_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "validation_type"
    t.string   "response_identifier"
    t.string   "relational_operator"
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "transaction_id"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

end
