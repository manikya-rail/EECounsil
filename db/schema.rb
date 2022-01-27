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

ActiveRecord::Schema.define(version: 2020_12_01_093858) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer "user_id"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "timezone"
    t.string "house_num"
  end

  create_table "available_days", force: :cascade do |t|
    t.integer "availablity_id"
    t.date "available_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.datetime "end_time"
  end

  create_table "available_slots", force: :cascade do |t|
    t.bigint "available_day_id"
    t.string "status", default: "available"
    t.integer "therapist_id"
    t.bigint "availablity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.index ["available_day_id"], name: "index_available_slots_on_available_day_id"
    t.index ["availablity_id"], name: "index_available_slots_on_availablity_id"
  end

  create_table "availablities", force: :cascade do |t|
    t.integer "therapist_id"
    t.integer "by_period"
    t.date "start_day"
    t.date "end_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "unavailable_start_time"
    t.time "unavailable_end_time"
    t.time "start_time"
    t.time "end_time"
  end

  create_table "blogs", force: :cascade do |t|
    t.bigint "category_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["category_id"], name: "index_blogs_on_category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_consent_forms", force: :cascade do |t|
    t.integer "consent_form_id"
    t.integer "therapist_id"
    t.integer "patient_id"
    t.text "consent_form_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_values"
  end

  create_table "consent_forms", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "course_sessions", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.float "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "free_months"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "diagnosis_codes", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "diagnosis_treatment_notes", force: :cascade do |t|
    t.string "diagnosis_code_ids"
    t.datetime "diagnosis_date"
    t.datetime "diagnosis_time"
    t.string "presenting_problem"
    t.text "goal"
    t.text "objective"
    t.string "treatment_frequency"
    t.datetime "assigned_treatment_date"
    t.datetime "assigned_treatment_time"
    t.string "schedule_id"
    t.string "patient_id"
    t.string "therapist_id"
    t.boolean "treatment_notes_added"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "electronic_notes", force: :cascade do |t|
    t.integer "video_call_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "schedule_id"
    t.integer "therapist_id"
    t.integer "patient_id"
  end

  create_table "features", force: :cascade do |t|
    t.string "feature_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interventions", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media", force: :cascade do |t|
    t.integer "user_id"
    t.string "item"
    t.integer "mediable_id"
    t.string "mediable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media_notes", force: :cascade do |t|
    t.string "item"
    t.integer "therapist_id"
    t.integer "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recipient_id"
    t.integer "user_id"
    t.string "action"
    t.integer "schedule_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.string "message_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "schedule_id"
    t.string "type"
    t.string "meeting_id"
    t.string "join_url"
    t.string "host_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "recipient_id"
    t.string "action"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "schedule_id"
    t.string "schedule_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "package_plans", force: :cascade do |t|
    t.bigint "package_id"
    t.integer "plan_type"
    t.integer "quantity", default: 1
    t.integer "interval"
    t.integer "price_per_quantity"
    t.integer "total_price"
    t.float "time_duration_in_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["package_id"], name: "index_package_plans_on_package_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.string "details"
    t.integer "package_total"
    t.integer "validity_in_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration"
    t.integer "duration_interval"
  end

  create_table "patient_claims", force: :cascade do |t|
    t.integer "therapist_id"
    t.integer "patient_id"
    t.integer "schedule_id"
    t.string "control_number"
    t.string "trading_partner_service_id"
    t.string "payment_responsibility_level_code"
    t.string "provider_type"
    t.string "claim_codes"
    t.string "patient_control_number"
    t.string "place_of_service_code"
    t.string "claim_frequency_code"
    t.string "signature_indicator"
    t.string "plan_participation_code"
    t.string "accept_assignment"
    t.string "release_information_code"
    t.string "diagnosis_identifier"
    t.string "diagnosis_code"
    t.date "date_of_service_from"
    t.date "date_of_service_to"
    t.string "procedure_identifier"
    t.string "procedure_code"
    t.string "measurement_unit"
    t.string "service_unit_count"
    t.string "diagnosis_code_pointers"
    t.string "status"
    t.string "coverage_type"
    t.string "patient_member_id"
    t.string "patient_name"
    t.string "patient_dob"
    t.string "patient_gender"
    t.string "patient_street_address"
    t.string "patient_city"
    t.string "patient_state"
    t.string "patient_zip"
    t.string "patient_phone"
    t.string "patient_relation_to_insured", default: "self"
    t.string "insured_name"
    t.string "insured_street_address"
    t.string "insured_city"
    t.string "insured_state"
    t.string "insured_zip"
    t.string "insured_phone"
    t.string "insured_policy_number"
    t.string "insured_dob"
    t.string "insured_gender"
    t.string "insured_plan_name"
    t.string "therapist_name"
    t.string "therapist_npi"
    t.string "charges"
    t.string "days_or_units"
    t.string "therapist_ssn"
    t.string "amount_paid"
    t.string "patient_account_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "therapist_city"
    t.string "therapist_zip"
    t.string "therapist_state"
    t.string "therapist_phone"
    t.string "claim_number"
    t.index ["patient_account_no"], name: "index_patient_claims_on_patient_account_no", unique: true
  end

  create_table "patient_eligibilities", force: :cascade do |t|
    t.integer "patient_id"
    t.integer "therapist_id"
    t.bigint "schedule_id"
    t.string "control_number"
    t.string "trading_service_payer_id"
    t.string "eligible"
    t.string "deductible"
    t.string "co_pay"
    t.string "co_insurance"
    t.string "out_of_pocket"
    t.string "claim_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pre_amount", default: "0"
    t.index ["schedule_id"], name: "index_patient_eligibilities_on_schedule_id"
  end

  create_table "patient_package_plans", force: :cascade do |t|
    t.integer "patient_package_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "plan_type"
    t.integer "quantity"
    t.integer "interval"
    t.float "time_duration_in_hours"
    t.integer "remaining_count"
    t.integer "completed_count", default: 0
    t.integer "price_per_quantity"
  end

  create_table "patient_package_therapists", force: :cascade do |t|
    t.bigint "patient_package_id"
    t.integer "therapist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_package_id"], name: "index_patient_package_therapists_on_patient_package_id"
  end

  create_table "patient_packages", force: :cascade do |t|
    t.integer "patient_id"
    t.bigint "package_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expiry_date"
    t.index ["package_id"], name: "index_patient_packages_on_package_id"
  end

  create_table "payers", force: :cascade do |t|
    t.string "payer_id"
    t.string "payer_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_plans", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "amount"
    t.string "currency"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_plan_id"
    t.boolean "block", default: false
    t.integer "trial_period"
    t.string "time_period"
    t.index ["user_id"], name: "index_payment_plans_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "paid_by"
    t.float "amount_paid"
    t.string "transaction_id"
    t.integer "paid_to"
    t.integer "paid_for"
    t.string "status"
  end

  create_table "place_of_service_codes", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_features", force: :cascade do |t|
    t.integer "plan_id"
    t.integer "feature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "procedure_codes", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.string "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promo_codes", force: :cascade do |t|
    t.integer "promo_type"
    t.float "promo_value"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration_in_months"
  end

  create_table "promos", force: :cascade do |t|
    t.integer "therapist_id"
    t.bigint "promo_code_id"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["promo_code_id"], name: "index_promos_on_promo_code_id"
  end

  create_table "questionnaire_answers", force: :cascade do |t|
    t.integer "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "patient_id"
    t.integer "questionnaire_choice_id"
  end

  create_table "questionnaire_choices", force: :cascade do |t|
    t.text "option"
    t.integer "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "skill"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.integer "question_type"
    t.text "question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "risk_factors", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "schedule_charges", force: :cascade do |t|
    t.string "status"
    t.bigint "schedule_id"
    t.string "description"
    t.string "charge_id"
    t.integer "therapist_id"
    t.integer "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transfer_id"
    t.integer "amount"
    t.index ["schedule_id"], name: "index_schedule_charges_on_schedule_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "therapist_id"
    t.integer "patient_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "schedule_date"
    t.integer "patient_package_plan_id"
    t.float "therapist_fees"
    t.float "admin_fees"
    t.boolean "paid_to_therapist", default: false
    t.string "scheduled_by", default: "patient"
    t.integer "procedure_code_id"
  end

  create_table "service_codes", force: :cascade do |t|
    t.string "service_type_code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "simple_notes", force: :cascade do |t|
    t.text "content"
    t.string "schedule_id"
    t.string "patient_id"
    t.string "therapist_id"
    t.boolean "draft"
    t.boolean "online"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "social_profiles", force: :cascade do |t|
    t.integer "user_id"
    t.integer "social_profile_type"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_notes", force: :cascade do |t|
    t.text "summary"
    t.string "schedule_id"
    t.string "patient_id"
    t.string "therapist_id"
    t.boolean "draft"
    t.boolean "online"
    t.string "cognitive_functioning"
    t.string "affect"
    t.string "mood"
    t.string "interpersonal"
    t.string "functional_status"
    t.string "risk_factor_ids"
    t.text "medications"
    t.text "current_functioning"
    t.text "topics_discussed"
    t.string "intervention_ids"
    t.string "treatment_plan_objective_1"
    t.string "treatment_plan_objective_2"
    t.text "additional_notes"
    t.text "plan"
    t.string "recommendation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "payment_plan_id"
    t.string "status"
    t.string "stripe_subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_plan_id"], name: "index_subscriptions_on_payment_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "therapist_courses", force: :cascade do |t|
    t.integer "course_id"
    t.integer "therapist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "trail_date"
    t.boolean "purchased", default: false
    t.integer "user_id"
  end

  create_table "therapist_rate_per_clients", force: :cascade do |t|
    t.integer "therapist_id"
    t.string "email", null: false
    t.integer "patient_id"
    t.integer "default_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_therapist_rate_per_clients_on_email", unique: true
  end

  create_table "unavailabilities", force: :cascade do |t|
    t.integer "available_day_id"
    t.time "unavailable_start_time"
    t.time "unavailable_end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_insurance_details", force: :cascade do |t|
    t.bigint "user_id"
    t.string "npi"
    t.string "tax_id"
    t.string "ssn"
    t.string "member_id"
    t.string "group_number"
    t.string "policy_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_insurance_details_on_user_id"
  end

  create_table "user_media", force: :cascade do |t|
    t.integer "user_id"
    t.string "item"
    t.integer "media_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_notes", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "patient_id"
    t.integer "therapist_id"
    t.string "action"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_payers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "payer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payer_id"], name: "index_user_payers_on_payer_id"
    t.index ["user_id"], name: "index_user_payers_on_user_id"
  end

  create_table "user_payment_modes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "payment_mode"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
    t.string "birth_date"
    t.boolean "status", default: false
    t.boolean "approved", default: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role_name"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.json "tokens"
    t.boolean "allow_password_change", default: false
    t.string "therapist_skills", default: [], array: true
    t.string "phone_number"
    t.string "added_by"
    t.integer "schedule_alert_time", default: 60
    t.string "stripe_connect_account_id"
    t.string "stripe_bank_account_id"
    t.datetime "deleted_at"
    t.string "plan_id"
    t.string "own_url"
    t.integer "therapist_id"
    t.string "logo"
    t.string "subscription_id"
    t.string "cancel_percentage"
    t.integer "per_slot_charges"
    t.string "therapist_type"
    t.boolean "is_zoom_user", default: false
    t.string "stripe_plan_id"
    t.text "about_me"
    t.string "practice_name"
    t.string "time_zone", default: "Eastern Time (US & Canada)"
    t.string "current_login_device"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "videos", force: :cascade do |t|
    t.string "description"
    t.boolean "home_intro_video"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zoom_integrations", force: :cascade do |t|
    t.string "config_name"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "available_slots", "available_days"
  add_foreign_key "available_slots", "availablities"
  add_foreign_key "blogs", "categories"
  add_foreign_key "notifications", "users"
  add_foreign_key "package_plans", "packages"
  add_foreign_key "patient_eligibilities", "schedules"
  add_foreign_key "patient_package_therapists", "patient_packages"
  add_foreign_key "patient_packages", "packages"
  add_foreign_key "payment_plans", "users"
  add_foreign_key "promos", "promo_codes"
  add_foreign_key "schedule_charges", "schedules"
  add_foreign_key "subscriptions", "payment_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_insurance_details", "users"
  add_foreign_key "user_payers", "payers"
  add_foreign_key "user_payers", "users"
end
