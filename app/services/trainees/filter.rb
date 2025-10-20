# frozen_string_literal: true

module Trainees
  class Filter
    include ServicePattern

    ALL_SCIENCES_FILTER = "Sciences - biology, chemistry, physics"

    def initialize(trainees:, filters:)
      @trainees = remove_hesa_trn_data_trainees_and_empty_trainees(trainees)
      @filters = filters
    end

    def call
      return trainees unless filters

      filter_trainees
    end

  private

    attr_reader :trainees, :filters

    def remove_empty_or_discarded_trainees(trainees)
      trainees.where.not(id: FindEmptyTrainees.call(trainees: trainees, ids_only: true)).undiscarded
    end

    def remove_hesa_trn_data_trainees(trainees)
      visible_sources = Trainee::ALL + [nil]
      trainees.where(record_source: visible_sources)
    end

    def remove_hesa_trn_data_trainees_and_empty_trainees(trainees)
      remove_hesa_trn_data_trainees(remove_empty_or_discarded_trainees(trainees))
    end

    def academic_year(trainees, academic_years)
      return trainees if academic_years.blank?

      scoped_trainees = trainees
      academic_years.each_with_index do |academic_year, i|
        academic_cycle = AcademicCycle.for_year(academic_year)

        if i.zero?
          scoped_trainees = academic_cycle.total_trainees
        else
          scoped_trainees = scoped_trainees.or(academic_cycle.total_trainees)
        end
      end

      trainees.merge(scoped_trainees)
    end

    def course_education_phase(trainees, course_education_phases)
      return trainees if course_education_phases.blank?

      trainees.where(course_education_phase: course_education_phases)
    end

    def record_source(trainees, record_source_values)
      scope_map = {
        "dttp" => :dttp_record,
        "manual" => :manual_record,
        "apply" => :with_apply_application,
        "hesa" => :imported_from_hesa,
      }
      scoped_trainees = trainees

      Array(record_source_values).each_with_index do |source, i|
        scope_name = scope_map[source]

        if i.zero?
          scoped_trainees = scoped_trainees.public_send(scope_name)
        else
          scoped_trainees = scoped_trainees.or(trainees.public_send(scope_name))
        end
      end

      scoped_trainees
    end

    def training_route(trainees, training_route)
      return trainees if training_route.blank?

      trainees.where(training_route:)
    end

    def status(trainees, statuses)
      return trainees if statuses.blank?

      scoped_trainees = trainees

      statuses.each_with_index do |status, i|
        if i.zero?
          scoped_trainees = scoped_trainees.public_send(status)
        else
          scoped_trainees = scoped_trainees.or(trainees.public_send(status))
        end
      end
      scoped_trainees
    end

    def subject(trainees, subject)
      return trainees if subject.blank?

      if subject == ALL_SCIENCES_FILTER
        return trainees_on_science_courses(trainees)
      end

      trainees.with_subject_or_allocation_subject(subject)
    end

    def start_year(trainees, cycle_start_year)
      return trainees if cycle_start_year.blank?

      academic_cycle_scope = AcademicCycle.for_year(cycle_start_year).trainees_starting

      trainees.merge(academic_cycle_scope)
    end

    def end_year(trainees, cycle_start_year)
      return trainees if cycle_start_year.blank?

      academic_cycle_scope = AcademicCycle.for_year(cycle_start_year).trainees_ending

      trainees.merge(academic_cycle_scope)
    end

    def trainees_on_science_courses(trainees)
      trainees.with_subject_or_allocation_subject(AllocationSubjects::PHYSICS.downcase)
              .or(trainees.with_subject_or_allocation_subject(AllocationSubjects::CHEMISTRY.downcase)
              .or(trainees.with_subject_or_allocation_subject(AllocationSubjects::BIOLOGY.downcase))
              .or(trainees.with_subject_or_allocation_subject(AllocationSubjects::GENERAL_SCIENCES.downcase)))
    end

    def text_search(trainees, text_search)
      return trainees if text_search.blank?

      trainees.with_name_provider_trainee_id_or_trn_like(text_search)
    end

    def provider(trainees, provider)
      return trainees if provider.blank?

      trainees.where(provider:)
    end

    def record_completion(trainees, record_completion)
      return trainees if record_completion.blank? || record_completion.size > 1

      if record_completion.include?("complete")
        trainees.complete
      else
        trainees.incomplete
      end
    end

    def study_mode(trainees, study_mode)
      return trainees if study_mode.blank? || (study_mode.count == 2)

      if study_mode.one?
        trainees.where(study_mode:).where.not(training_route: "assessment_only").where.not(training_route: "early_years_assessment_only")
      end
    end

    def trn(trainees, has_trn)
      return trainees if has_trn.nil?

      if has_trn
        trainees.with_trn
      else
        trainees.without_trn
      end
    end

    def not_withdrawn_before(filtered_trainees, date)
      return filtered_trainees if date.nil?

      filtered_trainees.left_outer_joins(:trainee_withdrawals).where.not(state: :withdrawn)
        .or(Trainee.left_outer_joins(:trainee_withdrawals).where("trainee_withdrawals.date >= ?", date))
    end

    def filter_trainees
      filtered_trainees = trainees

      filtered_trainees = academic_year(filtered_trainees, filters[:academic_year])
      filtered_trainees = training_route(filtered_trainees, filters[:training_route])
      filtered_trainees = status(filtered_trainees, filters[:status])
      filtered_trainees = subject(filtered_trainees, filters[:subject])
      filtered_trainees = start_year(filtered_trainees, filters[:start_year])
      filtered_trainees = end_year(filtered_trainees, filters[:end_year])
      filtered_trainees = text_search(filtered_trainees, filters[:text_search])
      filtered_trainees = course_education_phase(filtered_trainees, filters[:level])
      filtered_trainees = provider(filtered_trainees, filters[:provider])
      filtered_trainees = record_completion(filtered_trainees, filters[:record_completion])
      filtered_trainees = study_mode(filtered_trainees, filters[:study_mode])
      filtered_trainees = trn(filtered_trainees, filters[:has_trn])
      filtered_trainees = not_withdrawn_before(filtered_trainees, filters[:not_withdrawn_before])

      record_source(filtered_trainees, filters[:record_source])
    end
  end
end
