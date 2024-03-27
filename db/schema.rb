# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_22_114535) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_enum :feedbacks_categories, [
    "need",
    "need_reminder",
    "solicitation",
    "expert_reminder",
  ], force: :cascade

  create_enum :match_status, [
    "quo",
    "taking_care",
    "done",
    "done_no_help",
    "done_not_reachable",
    "not_for_me",
  ], force: :cascade

  create_enum :need_status, [
    "diagnosis_not_complete",
    "quo",
    "taking_care",
    "done",
    "not_for_me",
    "done_no_help",
    "done_not_reachable",
  ], force: :cascade

  create_enum :quarterly_reports_categories, [
    "matches",
    "stats",
  ], force: :cascade

  create_enum :territorial_level, [
    "local",
    "regional",
    "national",
  ], force: :cascade

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_subject_questions", force: :cascade do |t|
    t.bigint "subject_id"
    t.string "key"
    t.integer "position"
    t.index ["subject_id", "key"], name: "additional_subject_question_subject_key_index", unique: true
    t.index ["subject_id"], name: "index_additional_subject_questions_on_subject_id"
  end

  create_table "antennes", force: :cascade do |t|
    t.string "name"
    t.bigint "institution_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.enum "territorial_level", default: "local", null: false, enum_type: "territorial_level"
    t.bigint "parent_antenne_id"
    t.index ["deleted_at"], name: "index_antennes_on_deleted_at"
    t.index ["institution_id"], name: "index_antennes_on_institution_id"
    t.index ["name", "deleted_at", "institution_id"], name: "index_antennes_on_name_and_deleted_at_and_institution_id"
    t.index ["parent_antenne_id"], name: "index_antennes_on_parent_antenne_id"
    t.index ["territorial_level"], name: "index_antennes_on_territorial_level"
    t.index ["updated_at"], name: "index_antennes_on_updated_at"
  end

  create_table "antennes_communes", id: false, force: :cascade do |t|
    t.bigint "antenne_id", null: false
    t.bigint "commune_id", null: false
    t.index ["antenne_id"], name: "index_antennes_communes_on_antenne_id"
    t.index ["commune_id"], name: "index_antennes_communes_on_commune_id"
  end

  create_table "api_keys", force: :cascade do |t|
    t.bigint "institution_id", null: false
    t.string "token_digest", null: false
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id"], name: "index_api_keys_on_institution_id"
    t.index ["token_digest"], name: "index_api_keys_on_token_digest", unique: true
  end

  create_table "badge_badgeables", force: :cascade do |t|
    t.bigint "badgeable_id", null: false
    t.string "badgeable_type", null: false
    t.bigint "badge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_badge_badgeables_on_badge_id"
  end

  create_table "badges", force: :cascade do |t|
    t.string "title", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_institutions", id: false, force: :cascade do |t|
    t.bigint "institution_id", null: false
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_categories_institutions_on_category_id"
    t.index ["institution_id"], name: "index_categories_institutions_on_institution_id"
  end

  create_table "communes", force: :cascade do |t|
    t.string "insee_code"
    t.index ["insee_code"], name: "index_communes_on_insee_code", unique: true
  end

  create_table "communes_experts", id: false, force: :cascade do |t|
    t.bigint "commune_id", null: false
    t.bigint "expert_id", null: false
    t.index ["commune_id"], name: "index_communes_experts_on_commune_id"
    t.index ["expert_id"], name: "index_communes_experts_on_expert_id"
  end

  create_table "communes_territories", force: :cascade do |t|
    t.bigint "territory_id", null: false
    t.bigint "commune_id", null: false
    t.index ["commune_id"], name: "index_communes_territories_on_commune_id"
    t.index ["territory_id"], name: "index_communes_territories_on_territory_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "siren"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "legal_form_code"
    t.string "code_effectif"
    t.date "date_de_creation"
    t.boolean "inscrit_rcs"
    t.boolean "inscrit_rm"
    t.float "effectif"
    t.string "forme_exercice"
    t.boolean "activite_liberale", default: false
    t.boolean "independant", default: false
    t.index ["siren"], name: "index_companies_on_siren", unique: true, where: "((siren)::text <> NULL::text)"
  end

  create_table "company_satisfactions", force: :cascade do |t|
    t.boolean "contacted_by_expert"
    t.boolean "useful_exchange"
    t.text "comment"
    t.bigint "need_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["need_id"], name: "index_company_satisfactions_on_need_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "full_name"
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "diagnoses", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "step", default: 1
    t.bigint "advisor_id"
    t.bigint "visitee_id"
    t.bigint "facility_id", null: false
    t.date "happened_on"
    t.bigint "solicitation_id"
    t.datetime "completed_at", precision: nil
    t.boolean "retention_email_sent", default: false
    t.index ["advisor_id"], name: "index_diagnoses_on_advisor_id"
    t.index ["facility_id"], name: "index_diagnoses_on_facility_id"
    t.index ["solicitation_id"], name: "index_diagnoses_on_solicitation_id"
    t.index ["visitee_id"], name: "index_diagnoses_on_visitee_id"
  end

  create_table "email_retentions", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "first_subject_id", null: false
    t.string "first_subject_label", null: false
    t.bigint "second_subject_id", null: false
    t.string "second_subject_label", null: false
    t.string "email_subject", null: false
    t.text "first_paragraph", null: false
    t.integer "waiting_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_subject_id"], name: "index_email_retentions_on_first_subject_id"
    t.index ["second_subject_id"], name: "index_email_retentions_on_second_subject_id"
    t.index ["subject_id"], name: "index_email_retentions_on_subject_id", unique: true
  end

  create_table "experts", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "job"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "full_name"
    t.bigint "antenne_id", null: false
    t.boolean "is_global_zone", default: false
    t.datetime "deleted_at", precision: nil
    t.index ["antenne_id"], name: "index_experts_on_antenne_id"
    t.index ["deleted_at"], name: "index_experts_on_deleted_at"
    t.index ["email"], name: "index_experts_on_email"
  end

  create_table "experts_subjects", force: :cascade do |t|
    t.string "intervention_criteria"
    t.bigint "expert_id"
    t.bigint "institution_subject_id"
    t.index ["expert_id", "institution_subject_id"], name: "index_experts_subjects_on_expert_id_and_institution_subject_id", unique: true
    t.index ["expert_id"], name: "index_experts_subjects_on_expert_id"
    t.index ["institution_subject_id"], name: "index_experts_subjects_on_institution_subject_id"
  end

  create_table "experts_users", id: false, force: :cascade do |t|
    t.bigint "expert_id", null: false
    t.bigint "user_id", null: false
    t.index ["expert_id", "user_id"], name: "index_experts_users_on_expert_id_and_user_id", unique: true
    t.index ["expert_id"], name: "index_experts_users_on_expert_id"
    t.index ["user_id"], name: "index_experts_users_on_user_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "siret"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "naf_code"
    t.string "readable_locality"
    t.bigint "commune_id", null: false
    t.string "code_effectif"
    t.string "naf_libelle"
    t.string "naf_code_a10"
    t.bigint "opco_id"
    t.float "effectif"
    t.index ["commune_id"], name: "index_facilities_on_commune_id"
    t.index ["company_id"], name: "index_facilities_on_company_id"
    t.index ["opco_id"], name: "index_facilities_on_opco_id"
    t.index ["siret"], name: "index_facilities_on_siret", unique: true, where: "((siret)::text <> NULL::text)"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.string "feedbackable_type"
    t.bigint "feedbackable_id"
    t.enum "category", null: false, enum_type: "feedbacks_categories"
    t.index ["category"], name: "index_feedbacks_on_category"
    t.index ["feedbackable_type", "feedbackable_id"], name: "index_feedbacks_on_feedbackable_type_and_feedbackable_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "institution_filters", force: :cascade do |t|
    t.bigint "additional_subject_question_id"
    t.string "institution_filtrable_type"
    t.bigint "institution_filtrable_id"
    t.boolean "filter_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["additional_subject_question_id"], name: "index_institution_filters_on_additional_subject_question_id"
    t.index ["institution_filtrable_id", "institution_filtrable_type", "additional_subject_question_id"], name: "institution_filtrable_additional_subject_question_index", unique: true
    t.index ["institution_filtrable_type", "institution_filtrable_id"], name: "index_institution_filters_on_institution_filtrable"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug", null: false
    t.boolean "show_on_list", default: false
    t.datetime "deleted_at", precision: nil
    t.integer "code_region"
    t.boolean "display_logo", default: true
    t.text "siren"
    t.string "france_competence_code"
    t.index ["code_region"], name: "index_institutions_on_code_region"
    t.index ["deleted_at"], name: "index_institutions_on_deleted_at"
    t.index ["name"], name: "index_institutions_on_name", unique: true
    t.index ["slug"], name: "index_institutions_on_slug", unique: true
    t.index ["updated_at"], name: "index_institutions_on_updated_at"
  end

  create_table "institutions_subjects", force: :cascade do |t|
    t.string "description"
    t.bigint "institution_id"
    t.bigint "subject_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["institution_id"], name: "index_institutions_subjects_on_institution_id"
    t.index ["subject_id", "institution_id", "description"], name: "unique_institution_subject_in_institution", unique: true
    t.index ["subject_id"], name: "index_institutions_subjects_on_subject_id"
    t.index ["updated_at"], name: "index_institutions_subjects_on_updated_at"
  end

  create_table "landing_joint_themes", force: :cascade do |t|
    t.bigint "landing_id"
    t.bigint "landing_theme_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landing_id"], name: "index_landing_joint_themes_on_landing_id"
    t.index ["landing_theme_id"], name: "index_landing_joint_themes_on_landing_theme_id"
  end

  create_table "landing_subjects", force: :cascade do |t|
    t.bigint "landing_theme_id", null: false
    t.bigint "subject_id", null: false
    t.string "title"
    t.string "slug"
    t.text "description"
    t.integer "position"
    t.string "meta_title"
    t.string "meta_description"
    t.string "form_title"
    t.text "form_description"
    t.text "description_explanation"
    t.boolean "requires_siret", default: true, null: false
    t.boolean "requires_requested_help_amount", default: false, null: false
    t.boolean "requires_location", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "display_region_logo", default: false
    t.datetime "archived_at", precision: nil
    t.text "description_prefill"
    t.index ["archived_at"], name: "index_landing_subjects_on_archived_at"
    t.index ["landing_theme_id"], name: "index_landing_subjects_on_landing_theme_id"
    t.index ["slug"], name: "index_landing_subjects_on_slug", unique: true
    t.index ["subject_id"], name: "index_landing_subjects_on_subject_id"
  end

  create_table "landing_themes", force: :cascade do |t|
    t.string "title"
    t.string "page_title"
    t.string "slug"
    t.text "description"
    t.string "meta_title"
    t.string "meta_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at", precision: nil
    t.index ["archived_at"], name: "index_landing_themes_on_archived_at"
    t.index ["slug"], name: "index_landing_themes_on_slug", unique: true
  end

  create_table "landings", force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "home_description", default: ""
    t.bigint "institution_id"
    t.string "meta_title"
    t.string "meta_description"
    t.string "title"
    t.string "custom_css"
    t.string "partner_url"
    t.boolean "emphasis", default: false
    t.string "main_logo"
    t.integer "layout", default: 1
    t.integer "iframe_category", default: 1
    t.boolean "display_pde_partnership_mention", default: false
    t.datetime "archived_at", precision: nil
    t.integer "integration", default: 0
    t.index ["archived_at"], name: "index_landings_on_archived_at"
    t.index ["institution_id"], name: "index_landings_on_institution_id"
    t.index ["slug"], name: "index_landings_on_slug", unique: true
  end

  create_table "logos", force: :cascade do |t|
    t.string "filename"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "institution_id"
    t.index ["institution_id"], name: "index_logos_on_institution_id"
  end

  create_table "match_filters", force: :cascade do |t|
    t.string "accepted_naf_codes", array: true
    t.integer "effectif_min"
    t.integer "effectif_max"
    t.integer "min_years_of_existence"
    t.bigint "antenne_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_years_of_existence"
    t.string "accepted_legal_forms", array: true
    t.string "excluded_legal_forms", array: true
    t.string "excluded_naf_codes", array: true
    t.index ["antenne_id"], name: "index_match_filters_on_antenne_id"
  end

  create_table "match_filters_subjects", id: false, force: :cascade do |t|
    t.bigint "match_filter_id"
    t.bigint "subject_id"
    t.index ["match_filter_id"], name: "index_match_filters_subjects_on_match_filter_id"
    t.index ["subject_id"], name: "index_match_filters_subjects_on_subject_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "taken_care_of_at", precision: nil
    t.datetime "closed_at", precision: nil
    t.bigint "expert_id", null: false
    t.bigint "subject_id", null: false
    t.enum "status", default: "quo", null: false, enum_type: "match_status"
    t.datetime "archived_at", precision: nil
    t.datetime "sent_at", precision: nil
    t.index ["expert_id", "need_id"], name: "index_matches_on_expert_id_and_need_id", unique: true, where: "(expert_id <> NULL::bigint)"
    t.index ["expert_id"], name: "index_matches_on_expert_id"
    t.index ["need_id"], name: "index_matches_on_need_id"
    t.index ["status"], name: "index_matches_on_status"
    t.index ["subject_id"], name: "index_matches_on_subject_id"
  end

  create_table "needs", force: :cascade do |t|
    t.bigint "diagnosis_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "content"
    t.integer "matches_count"
    t.boolean "satisfaction_email_sent", default: false, null: false
    t.enum "status", default: "diagnosis_not_complete", null: false, enum_type: "need_status"
    t.boolean "abandoned_email_sent", default: false
    t.datetime "retention_sent_at", precision: nil
    t.datetime "starred_at", precision: nil
    t.index ["diagnosis_id"], name: "index_needs_on_diagnosis_id"
    t.index ["status"], name: "index_needs_on_status"
    t.index ["subject_id", "diagnosis_id"], name: "index_needs_on_subject_id_and_diagnosis_id", unique: true
    t.index ["subject_id"], name: "index_needs_on_subject_id"
  end

  create_table "quarterly_reports", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.bigint "antenne_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "category", enum_type: "quarterly_reports_categories"
    t.index ["antenne_id"], name: "index_quarterly_reports_on_antenne_id"
    t.index ["category"], name: "index_quarterly_reports_on_category"
  end

  create_table "referencement_coverages", force: :cascade do |t|
    t.bigint "antenne_id", null: false
    t.bigint "institution_subject_id", null: false
    t.string "coverage"
    t.integer "anomalie"
    t.json "anomalie_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["antenne_id"], name: "index_referencement_coverages_on_antenne_id"
    t.index ["institution_subject_id"], name: "index_referencement_coverages_on_institution_subject_id"
  end

  create_table "reminders_actions", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", null: false
    t.index ["need_id", "category"], name: "index_reminders_actions_on_need_id_and_category", unique: true
    t.index ["need_id"], name: "index_reminders_actions_on_need_id"
  end

  create_table "reminders_registers", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.integer "basket"
    t.bigint "expert_id", null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "run_number", null: false
    t.integer "expired_count", default: 0
    t.index ["expert_id"], name: "index_reminders_registers_on_expert_id"
    t.index ["run_number", "expert_id"], name: "index_reminders_registers_on_run_number_and_expert_id", unique: true
  end

  create_table "solicitations", force: :cascade do |t|
    t.string "description"
    t.string "email"
    t.string "phone_number"
    t.jsonb "form_info", default: {}
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "siret"
    t.string "full_name"
    t.string "landing_slug"
    t.jsonb "prepare_diagnosis_errors_details", default: {}
    t.string "requested_help_amount"
    t.string "location"
    t.bigint "institution_id"
    t.integer "code_region"
    t.bigint "landing_id"
    t.bigint "landing_subject_id"
    t.integer "status", default: 0
    t.uuid "uuid"
    t.datetime "completed_at", precision: nil
    t.index ["code_region"], name: "index_solicitations_on_code_region"
    t.index ["email"], name: "index_solicitations_on_email"
    t.index ["institution_id"], name: "index_solicitations_on_institution_id"
    t.index ["landing_id"], name: "index_solicitations_on_landing_id"
    t.index ["landing_slug"], name: "index_solicitations_on_landing_slug"
    t.index ["landing_subject_id"], name: "index_solicitations_on_landing_subject_id"
    t.index ["status"], name: "index_solicitations_on_status"
    t.index ["uuid"], name: "index_solicitations_on_uuid"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.string "label", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "theme_id", null: false
    t.integer "interview_sort_order"
    t.datetime "archived_at", precision: nil
    t.boolean "is_support", default: false
    t.string "slug", null: false
    t.index ["archived_at"], name: "index_subjects_on_archived_at"
    t.index ["interview_sort_order"], name: "index_subjects_on_interview_sort_order"
    t.index ["label"], name: "index_subjects_on_label", unique: true
    t.index ["slug"], name: "index_subjects_on_slug", unique: true
    t.index ["theme_id"], name: "index_subjects_on_theme_id"
  end

  create_table "territories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "bassin_emploi", default: false, null: false
    t.bigint "support_contact_id"
    t.integer "code_region"
    t.index ["code_region"], name: "index_territories_on_code_region", unique: true
    t.index ["support_contact_id"], name: "index_territories_on_support_contact_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "label", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "interview_sort_order"
    t.index ["interview_sort_order"], name: "index_themes_on_interview_sort_order"
    t.index ["label"], name: "index_themes_on_label", unique: true
    t.index ["updated_at"], name: "index_themes_on_updated_at"
  end

  create_table "user_rights", force: :cascade do |t|
    t.bigint "antenne_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", null: false
    t.index ["antenne_id"], name: "index_user_rights_on_antenne_id"
    t.index ["user_id", "antenne_id", "category"], name: "index_user_rights_on_user_id_and_antenne_id_and_category", unique: true
    t.index ["user_id"], name: "index_user_rights_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "phone_number"
    t.string "job"
    t.string "full_name"
    t.bigint "antenne_id", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.bigint "inviter_id"
    t.integer "invitations_count", default: 0
    t.datetime "deleted_at", precision: nil
    t.datetime "cgu_accepted_at", precision: nil
    t.index ["antenne_id"], name: "index_users_on_antenne_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email)::text <> NULL::text)"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["inviter_id"], name: "index_users_on_inviter_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "antennes", "institutions"
  add_foreign_key "antennes_communes", "antennes"
  add_foreign_key "antennes_communes", "communes"
  add_foreign_key "api_keys", "institutions"
  add_foreign_key "badge_badgeables", "badges"
  add_foreign_key "communes_experts", "communes"
  add_foreign_key "communes_experts", "experts"
  add_foreign_key "communes_territories", "communes"
  add_foreign_key "communes_territories", "territories"
  add_foreign_key "company_satisfactions", "needs"
  add_foreign_key "contacts", "companies"
  add_foreign_key "diagnoses", "contacts", column: "visitee_id"
  add_foreign_key "diagnoses", "facilities"
  add_foreign_key "diagnoses", "solicitations"
  add_foreign_key "diagnoses", "users", column: "advisor_id"
  add_foreign_key "email_retentions", "subjects"
  add_foreign_key "email_retentions", "subjects", column: "first_subject_id"
  add_foreign_key "email_retentions", "subjects", column: "second_subject_id"
  add_foreign_key "experts", "antennes"
  add_foreign_key "experts_subjects", "experts"
  add_foreign_key "experts_subjects", "institutions_subjects"
  add_foreign_key "experts_users", "experts"
  add_foreign_key "experts_users", "users"
  add_foreign_key "facilities", "communes"
  add_foreign_key "facilities", "companies"
  add_foreign_key "facilities", "institutions", column: "opco_id"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "institutions_subjects", "institutions"
  add_foreign_key "institutions_subjects", "subjects"
  add_foreign_key "landing_subjects", "landing_themes"
  add_foreign_key "landing_subjects", "subjects"
  add_foreign_key "landings", "institutions"
  add_foreign_key "logos", "institutions"
  add_foreign_key "match_filters", "antennes"
  add_foreign_key "matches", "experts"
  add_foreign_key "matches", "needs"
  add_foreign_key "matches", "subjects"
  add_foreign_key "needs", "diagnoses"
  add_foreign_key "needs", "subjects"
  add_foreign_key "quarterly_reports", "antennes"
  add_foreign_key "referencement_coverages", "antennes"
  add_foreign_key "referencement_coverages", "institutions_subjects"
  add_foreign_key "reminders_actions", "needs"
  add_foreign_key "reminders_registers", "experts"
  add_foreign_key "solicitations", "institutions"
  add_foreign_key "solicitations", "landing_subjects"
  add_foreign_key "solicitations", "landings"
  add_foreign_key "subjects", "themes"
  add_foreign_key "user_rights", "antennes"
  add_foreign_key "user_rights", "users"
  add_foreign_key "users", "antennes"
  add_foreign_key "users", "users", column: "inviter_id"
end
