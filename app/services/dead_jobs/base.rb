# frozen_string_literal: true

module DeadJobs
  class Base
    include Hashable

    def initialize(dead_set: Sidekiq::DeadSet.new, include_dqt_status: false, sort_by: :register)
      @dead_set = dead_set
      @include_dqt_status = include_dqt_status
      @sort_by = sort_by
    end

    def to_csv
      CSV.generate do |csv|
        csv << csv_headers
        trainees.each do |trainee|
          csv << build_csv_row(trainee).values
        end
      end
    end

    def headers
      return if rows.blank?

      rows.first.keys
    end

    def rows
      @rows ||= trainees.map { |trainee| build_html_row(trainee) }
    end

    def name
      @name ||= identifier.titleize.gsub(/(Dqt|Trs)/i, &:upcase)
    end

    def identifier
      @identifier ||= self.class.name.demodulize
    end

    def trainees
      Trainee.kept.includes(:provider, :dqt_teacher, :dqt_teacher_trainings).find(dead_jobs.keys)
    end

    delegate :count, to: :dead_jobs

  private

    attr_reader :dead_set, :include_dqt_status, :sort_by

    def csv_headers
      build_csv_row(trainees.first).keys
    end

    def build_csv_row(trainee)
      {
        register_id: trainee.id,
        job_id: dead_jobs[trainee.id][:job_id],
        url: "#{Settings.base_url}/trainees/#{trainee.slug}",
        trn: trainee.trn,
        date_of_birth: trainee.date_of_birth,
        full_name: trainee.full_name,
        email: trainee.email,
        state: trainee.state,
        provider_name: trainee.provider.name,
        provider_ukprn: trainee.provider.ukprn,
        training_route: trainee.training_route,
        itt_start_date: trainee.itt_start_date,
        itt_end_date: trainee.itt_start_date,
        course_min_age: trainee.course_min_age,
        course_max_age: trainee.course_max_age,
        course_subject_one: trainee.course_subject_one,
        course_subject_two: trainee.course_subject_two,
        course_subject_three: trainee.course_subject_three,
        error_message: dead_job_error_message(trainee.id),
        dqt: dqt(trainee),
      }
    end

    def build_html_row(trainee)
      {
        register_id: trainee.id,
        trn: trainee.trn,
        name: trainee.full_name,
        date_of_birth: trainee.date_of_birth,
        state: trainee.state,
        job_id: dead_jobs[trainee.id][:job_id],
        days_waiting: days_waiting_for(dead_jobs[trainee.id][:enqueued_at]),
      }
    end

    def days_waiting_for(enqueued_at)
      return nil unless enqueued_at

      (Time.zone.today - Time.zone.at(enqueued_at).to_date).to_i
    end

    def dqt(trainee)
      return unless include_dqt_status && trainee.trn.present? && dqt_record_available?(trainee)

      dqt_teacher_keys = %w[trn first_name last_name middle_name date_of_birth]
      dqt_teacher_training_keys = %w[programme_start_date programme_end_date programme_type result provider_ukprn hesa_id active]

      flatten_hash(
        trainee.dqt_teacher.attributes.slice(*dqt_teacher_keys).merge(
          dqt_teacher_trainings: trainee.dqt_teacher_trainings.map { |tt| tt.attributes.slice(*dqt_teacher_training_keys) },
        ),
      )
    end

    def dead_jobs
      return @dead_jobs if defined?(@dead_jobs)

      all_dead_jobs =
        dead_set
        .select { |job| job.item["wrapped"] == klass }
        .sort_by { |job| job.item["enqueued_at"] }
        .to_h do |job|
          arguments = job.item["args"].first["arguments"]

          [
            deep_dig(arguments, "_aj_globalid").split("/").last.to_i,
            {
              error_message: parse_error(job.item["error_message"]),
              job_id: job.item["jid"],
              enqueued_at: job.item["enqueued_at"],
            },
          ]
        end

      existing_trainee_ids = with_undiscarded_trainees(all_dead_jobs)
      @dead_jobs = all_dead_jobs.slice(*existing_trainee_ids)
    end

    def with_undiscarded_trainees(dead_jobs)
      Trainee.kept.where(id: dead_jobs.keys).pluck(:id)
    end

    def dead_job_error_message(trainee_id)
      dead_jobs[trainee_id][:error_message]&.to_s&.gsub('"', "'")
    end

    def parse_error(error)
      return error unless error.include?("body: ")

      JSON.parse(
        error.split("body: ")
             .last
             .split(", headers:")
             .first,
      )
    rescue JSON::ParserError
      error
    end

    def flatten_hash(hash, parent_key = "", result = "")
      hash.each do |key, value|
        new_key = parent_key == "" ? key.to_s : "#{parent_key}_#{key}"
        if value.is_a?(Hash)
          result = flatten_hash(value, new_key, result)
        else
          result += "#{new_key}: #{value}\n"
        end
      end
      result
    end

    def dqt_record_available?(trainee)
      trainee.dqt_teacher.present? && trainee.dqt_teacher_trainings.present?
    end
  end
end
