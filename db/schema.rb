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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_101340) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.text "brand_always_mention"
    t.text "brand_description"
    t.text "brand_never_say"
    t.text "brand_reply_guidelines"
    t.text "brand_sample_replies"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.boolean "notify_slack", default: false
    t.string "plan", default: "starter"
    t.string "slack_webhook_url"
    t.string "slug", null: false
    t.string "stripe_customer_id"
    t.string "subscription_status", default: "trialing"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
  end

  create_table "campaign_responses", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.boolean "clicked_external", default: false, null: false
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "customer_phone"
    t.text "feedback"
    t.string "outcome"
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_campaign_responses_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true
    t.string "campaign_type", default: "qr"
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.string "name", null: false
    t.integer "positive_threshold", default: 4
    t.string "redirect_platform", default: "google"
    t.integer "redirects_count", default: 0
    t.integer "responses_count", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_campaigns_on_account_id"
    t.index ["location_id"], name: "index_campaigns_on_location_id"
    t.index ["slug"], name: "index_campaigns_on_slug", unique: true
  end

  create_table "dashboard_summaries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "action_item"
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.jsonb "improvements"
    t.string "period"
    t.jsonb "strengths"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["account_id", "period"], name: "index_dashboard_summaries_on_account_id_and_period", unique: true
    t.index ["account_id"], name: "index_dashboard_summaries_on_account_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "PKR", null: false
    t.date "due_at", null: false
    t.date "issued_at", null: false
    t.text "notes"
    t.string "number", null: false
    t.datetime "paid_at"
    t.string "payment_method"
    t.string "payment_reference"
    t.string "status", default: "pending", null: false
    t.bigint "subscription_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_invoices_on_account_id_and_status"
    t.index ["account_id"], name: "index_invoices_on_account_id"
    t.index ["due_at"], name: "index_invoices_on_due_at"
    t.index ["number"], name: "index_invoices_on_number", unique: true
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "address"
    t.boolean "auto_generate_replies", default: true, null: false
    t.boolean "auto_post_replies", default: false, null: false
    t.float "average_rating"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "default_reply_tone", default: "professional", null: false
    t.string "facebook_page_id"
    t.string "google_account_id"
    t.boolean "google_connected", default: false
    t.string "google_location_id"
    t.datetime "google_oauth_expires_at"
    t.text "google_oauth_refresh_token_ciphertext"
    t.text "google_oauth_token_ciphertext"
    t.string "google_place_id"
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.string "phone"
    t.integer "total_reviews", default: 0
    t.string "tripadvisor_id"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_locations_on_account_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_daily_digest", default: true
    t.boolean "email_on_negative", default: true
    t.string "phone_number"
    t.boolean "slack_webhook_enabled", default: false
    t.string "slack_webhook_url"
    t.boolean "sms_on_negative", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "payment_proofs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.bigint "invoice_id", null: false
    t.datetime "reviewed_at"
    t.string "status", default: "pending_review", null: false
    t.datetime "submitted_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_payment_proofs_on_account_id"
    t.index ["invoice_id"], name: "index_payment_proofs_on_invoice_id"
    t.index ["status"], name: "index_payment_proofs_on_status"
    t.index ["submitted_at"], name: "index_payment_proofs_on_submitted_at"
  end

  create_table "plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "PKR", null: false
    t.jsonb "features", default: "{}", null: false
    t.integer "max_campaigns", null: false
    t.integer "max_locations", null: false
    t.integer "max_reviews_per_month", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.integer "price_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_plans_on_active"
    t.index ["position"], name: "index_plans_on_position"
  end

  create_table "platform_connections", force: :cascade do |t|
    t.string "access_token_ciphertext"
    t.datetime "created_at", null: false
    t.string "external_id"
    t.datetime "last_synced_at"
    t.bigint "location_id", null: false
    t.string "platform", null: false
    t.string "refresh_token_ciphertext"
    t.string "status", default: "active"
    t.datetime "token_expires_at"
    t.datetime "updated_at", null: false
    t.index ["location_id", "platform"], name: "index_platform_connections_on_location_id_and_platform", unique: true
    t.index ["location_id"], name: "index_platform_connections_on_location_id"
  end

  create_table "reply_drafts", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "review_id", null: false
    t.string "status", default: "draft"
    t.string "tone", default: "professional"
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_reply_drafts_on_review_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "body"
    t.jsonb "categories", default: []
    t.datetime "created_at", null: false
    t.string "external_review_id", null: false
    t.bigint "location_id", null: false
    t.jsonb "metadata", default: {}
    t.string "platform", null: false
    t.datetime "published_at"
    t.integer "rating"
    t.datetime "replied_at"
    t.text "reply"
    t.string "reply_status", default: "pending"
    t.string "reviewer_avatar_url"
    t.string "reviewer_name"
    t.string "sentiment"
    t.float "sentiment_score"
    t.datetime "updated_at", null: false
    t.index ["account_id", "platform", "external_review_id"], name: "index_reviews_unique_external", unique: true
    t.index ["account_id", "published_at"], name: "index_reviews_on_account_id_and_published_at"
    t.index ["account_id", "sentiment"], name: "index_reviews_on_account_id_and_sentiment"
    t.index ["account_id"], name: "index_reviews_on_account_id"
    t.index ["categories"], name: "index_reviews_on_categories", using: :gin
    t.index ["location_id"], name: "index_reviews_on_location_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.date "current_period_end"
    t.date "current_period_start"
    t.bigint "plan_id", null: false
    t.string "status", default: "trial", null: false
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_subscriptions_on_account_id"
    t.index ["current_period_end"], name: "index_subscriptions_on_current_period_end"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["trial_ends_at"], name: "index_subscriptions_on_trial_ends_at"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.string "role", default: "member"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "campaign_responses", "campaigns"
  add_foreign_key "campaigns", "accounts"
  add_foreign_key "campaigns", "locations"
  add_foreign_key "dashboard_summaries", "accounts"
  add_foreign_key "invoices", "accounts"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "locations", "accounts"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "payment_proofs", "accounts"
  add_foreign_key "payment_proofs", "invoices"
  add_foreign_key "platform_connections", "locations"
  add_foreign_key "reply_drafts", "reviews"
  add_foreign_key "reviews", "accounts"
  add_foreign_key "reviews", "locations"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "subscriptions", "accounts"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "users", "accounts"
end
