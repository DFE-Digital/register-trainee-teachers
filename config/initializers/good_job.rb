# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    preserve_job_records: true,
    retry_on_unhandled_error: false,
    on_thread_error: -> (exception) { Rails.error.report(exception) },
    execution_mode: :async,
    queues: "high_priority:2;default:2;dqt:2;apply:2;hesa:2;dttp:2;mailers:2;dqt_sync:2;dfe_analytics:2;others:2;bulk_update:2",
    max_threads: 5,
    poll_interval: 30,
    shutdown_timeout: 25,
    enable_cron: true,
    cron: {
      import_collection_from_hesa: {
        cron: "0 8-23/2 * * *", # every 2 hours, starting at 08:00 and ending at 23:59
        class: "Hesa::RetrieveCollectionJob",
        queue: :hesa,
      },
      import_trn_data_from_hesa: {
        cron: "30 8-23/2 * * *", # 30 minutes past every 2nd hour from 8 through 23
        class: "Hesa::RetrieveTrnDataJob",
        queue: :hesa,
      },
      malware_scan_uploads: {
        cron: "*/20 * * * *", # Every 20 minutes of every day.
        class: "MalwareScanningJob",
        queue: :default,
      },
      remove_duplicate_dead_jobs: {
        cron: "*/5 * * * *", # Every 5 minutes of every day.
        class: "Sidekiq::RemoveDeadDuplicatesJob",
        queue: :default,
      },
      # Jobs that run once a day at a specific time, sorted by their running time
      truncate_activerecord_session_store: {
        cron: "0 0 * * *", # Every day at 00:00 (midnight).
        class: "SessionStoreTruncateJob",
        queue: :default,
      },
      delete_empty_trainees: {
        cron: "0 0 * * *", # Every day at 00:00 (midnight).
        class: "DeleteEmptyTraineesJob",
        queue: :default,
      },
      import_applications_from_apply: {
        cron: "0 1 * * *", # Every day at 01:00.
        class: "RecruitsApi::ImportApplicationsJob",
        queue: :default,
      },
      import_subjects_from_ttapi: {
        cron: "0 2 * * *", # Every day at 02:00.
        class: "TeacherTrainingApi::ImportSubjectsJob",
        queue: :default,
      },
      import_courses_from_ttapi: {
        cron: "0 3 * * *", # Every day at 03:00.
        class: "TeacherTrainingApi::ImportCoursesJob",
        queue: :default,
      },
      create_trainees_from_apply: {
        cron: ENV.fetch("RAILS_ENV") == "sandbox" ? "" : "0 4 * * *", # Every day at 04:00 unless in sandbox
        class: "Trainees::CreateFromApplyJob",
        queue: :default,
      },
      sync_hesa_students: {
        cron: "0 5 * * *", # Every day at 05:00.
        class: "Hesa::SyncStudentsJob",
        queue: :hesa,
      },
      upload_trn_file_to_hesa: {
        cron: "10 10 * * *", # Every day at 10:10.
        class: "Hesa::UploadTrnFileJob",
        queue: :hesa,
      },
      send_entity_table_checks_to_bigquery: {
        cron: "30 0 * * *", # Every day at 00:30.
        class: "DfE::Analytics::EntityTableCheckJob",
        queue: :dfe_analytics,
      },

      # Jobs that run less than once a day
      sync_dqt_teachers: {
        cron: "0 2 * * 1", # Every Monday at 02:00.
        class: "Dqt::SyncTeachersJob",
        queue: :default,
      },
    },
    dashboard_default_locale: :en,
  }
end
