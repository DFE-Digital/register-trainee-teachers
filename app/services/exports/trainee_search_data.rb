# frozen_string_literal: true

module Exports
  class TraineeSearchData
    VULNERABLE_CHARACTERS = %w[= + - @].freeze

    def initialize(trainees)
      @data_for_export = format_trainees(trainees)
    end

    def data
      header_row ||= data_for_export.first&.keys

      CSV.generate(headers: true) do |rows|
        rows << header_row

        data_for_export.map(&:values).each do |value|
          rows << value.map { |v| sanitise(v) }
        end
      end
    end

    def filename
      "#{Time.zone.now.strftime('%Y-%m-%d_%H-%M_%S')}_Register-trainee-teachers_exported_records.csv"
    end

  private

    attr_reader :data_for_export

    def format_trainees(trainees)
      trainees.map do |trainee|
        degree = trainee.degrees.first
        course = Course.where(uuid: trainee.course_uuid).first
        {
          "register_id" => trainee.slug,
          "trainee_url" => "#{Settings.base_url}/trainees/#{trainee.slug}",
          "apply_id" => trainee.apply_application&.apply_id,
          "provider_trainee_id" => trainee.trainee_id,
          "trn" => trainee.trn,
          "status" => status(trainee),
          "academic_year" => nil,
          "updated_at" => trainee.updated_at&.iso8601,
          "record_created_at" => trainee.created_at&.iso8601,
          "submitted_for_trn_at" => trainee.submitted_for_trn_at&.iso8601,
          "provider_name" => trainee.provider&.name,
          "provider_id" => trainee.provider&.code,
          "first_names" => trainee.first_names,
          "middle_names" => trainee.middle_names,
          "last_names" => trainee.last_name,
          "date_of_birth" => trainee.date_of_birth&.iso8601,
          "gender" => gender(trainee),
          "nationalities" => trainee.nationalities.pluck(:name).map(&:titleize).join(", "),
          "address_line_1" => trainee.address_line_one,
          "address_line_2" => trainee.address_line_two,
          "town_city" => trainee.town_city,
          "postcode" => trainee.postcode,
          "international_address" => international_address(trainee),
          "email_address" => trainee.email,
          "diversity_disclosure" => diversity_disclosure(trainee),
          "ethnic_group" => ethnic_group(trainee),
          "ethnic_background" => trainee.ethnic_background,
          "ethnic_background_additional" => trainee.additional_ethnic_background,
          "disability_disclosure" => disability_disclosure(trainee),
          "disabilities" => disabilities(trainee),
          "number_of_degrees" => trainee.degrees.count,
          "degree_1_uk_or_non_uk" => uk_or_non_uk(degree),
          "degree_1_awarding_institution" => degree&.institution,
          "degree_1_country" => degree&.country,
          "degree_1_subject" => degree&.subject,
          "degree_1_type_of_degree" => degree&.uk_degree,
          "degree_1_non_uk_type" => degree&.non_uk_degree,
          "degree_1_grade" => degree&.grade,
          "degree_1_other_grade" => degree&.other_grade,
          "degree_1_graduation_year" => degree&.graduation_year,
          "degrees" => degrees(trainee),
          "course_code" => trainee.published_course&.code,
          "course_name" => course&.name,
          "course_route" => course_route(trainee),
          "course_qualification" => trainee.award_type,
          "course_education_phase" => trainee_education_phase(trainee) || course_education_phase(course),
          "course_allocation_subject" => trainee_allocation_subject(trainee.course_subject_one) || course_allocation_subject(course),
          "course_itt_subject_1" => trainee.course_subject_one,
          "course_itt_subject_2" => trainee.course_subject_two,
          "course_itt_subject_3" => trainee.course_subject_three,
          "course_min_age" => trainee.course_min_age,
          "course_max_age" => trainee.course_max_age,
          "course_study_mode" => course_study_mode(trainee),
          "course_level" => course_level(trainee),
          "itt_start_date" => trainee.itt_start_date&.iso8601,
          "itt_end_date" => trainee.itt_end_date&.iso8601,
          "course_duration_in_years" => trainee.course_duration_in_years,
          "course_summary" => course_summary(trainee, course),
          "commencement_date" => trainee.commencement_date&.iso8601,
          "lead_school_name" => lead_school_name(trainee),
          "lead_school_urn" => trainee.lead_school&.urn,
          "employing_school_name" => employing_school_name(trainee),
          "employing_school_urn" => trainee.employing_school&.urn,
          "training_initiative" => training_initiative(trainee),
          "funding_method" => funding_method(trainee),
          "funding_value" => funding_value(trainee),
          "bursary_tier" => bursary_tier(trainee),
          "award_standards_met_date" => trainee.outcome_date&.iso8601,
          "award_awarded_at" => trainee.awarded_at&.iso8601,
          "defer_date" => trainee.defer_date&.iso8601,
          "reinstate_date" => trainee.reinstate_date&.iso8601,
          "withdraw_date" => trainee.withdraw_date&.to_date&.iso8601,
          "withdraw_reason" => trainee.withdraw_reason,
          "additional_withdraw_reason" => trainee.additional_withdraw_reason,
        }
      end
    end

    def course_level(trainee)
      if trainee.undergrad_route?
        "undergrad"
      else
        "postgrad"
      end
    end

    def course_summary(trainee, course)
      return if course&.summary.blank?

      case trainee.study_mode
      when "part_time"
        course.summary.gsub(/(full time)/i, "part time")
      when "full_time"
        course.summary.gsub(/(part time)/i, "full time")
      end
    end

    def funding_manager(trainee)
      FundingManager.new(trainee)
    end

    def funding_method(trainee)
      if trainee.applying_for_bursary?
        FUNDING_TYPE_ENUMS[:bursary]
      elsif trainee.applying_for_scholarship?
        FUNDING_TYPE_ENUMS[:scholarship]
      elsif trainee.applying_for_grant?
        FUNDING_TYPE_ENUMS[:grant]
      elsif [trainee.applying_for_bursary, trainee.applying_for_scholarship, trainee.applying_for_grant].include?(false)
        "not funded"
      elsif !funding_manager(trainee).funding_available?
        "not available"
      end
    end

    def funding_value(trainee)
      funding_manager = funding_manager(trainee)

      if trainee.applying_for_bursary?
        funding_manager.bursary_amount
      elsif trainee.applying_for_scholarship?
        funding_manager.scholarship_amount
      elsif trainee.applying_for_grant?
        funding_manager.grant_amount
      end
    end

    def t(*args)
      I18n.t(*args)
    end

    def status(trainee)
      StatusTag::View.new(trainee: trainee).status
    end

    def gender(trainee)
      return if trainee.gender.blank?

      t("components.confirmation.personal_detail.genders.#{trainee.gender}")
    end

    def diversity_disclosure(trainee)
      {
        "diversity_disclosed" => "TRUE",
        "diversity_not_disclosed" => "FALSE",
      }[trainee.diversity_disclosure]
    end

    def ethnic_group(trainee)
      t("components.confirmation.diversity.ethnic_groups.#{trainee.ethnic_group.presence || 'not_provided_ethnic_group'}")
    end

    def disability_disclosure(trainee)
      {
        "disabled" => "TRUE",
        "no_disability" => "FALSE",
      }[trainee.disability_disclosure]
    end

    def disabilities(trainee)
      trainee.disabilities.map do |disability|
        if disability.name == Diversities::OTHER
          trainee.trainee_disabilities.where(disability_id: disability.id).first.additional_disability
        else
          disability.name
        end
      end.join(", ")
    end

    def uk_or_non_uk(degree)
      return unless degree

      {
        "uk" => "UK",
        "non_uk" => "non-UK",
      }[degree.locale_code]
    end

    def degrees(trainee)
      trainee.degrees.map do |degree|
        [
          uk_or_non_uk(degree),
          degree.institution,
          degree.country,
          degree.subject,
          degree.uk_degree,
          degree.non_uk_degree,
          degree.grade,
          degree.other_grade,
          degree.graduation_year,
        ].map { |d| "\"#{d}\"" }.join(", ")
      end.join(" | ")
    end

    def course_route(trainee)
      t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
    end

    def training_initiative(trainee)
      return unless trainee.training_initiative

      t("activerecord.attributes.trainee.training_initiatives.#{trainee.training_initiative}")
    end

    def bursary_tier(trainee)
      {
        "tier_one" => "Tier 1",
        "tier_two" => "Tier 2",
        "tier_three" => "Tier 3",
      }[trainee.bursary_tier]
    end

    def international_address(trainee)
      trainee.international_address.to_s.split(/[\r\n,]/).select(&:present?).join(", ")
    end

    def trainee_allocation_subject(subject)
      SubjectSpecialism.find_by(name: subject)&.allocation_subject&.name
    end

    def course_allocation_subject(course)
      return unless course

      subject = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name))
        .values.map(&:first).first

      trainee_allocation_subject(subject)
    end

    def trainee_education_phase(trainee)
      return EARLY_YEARS_ROUTE_NAME_PREFIX.humanize if trainee.early_years_route?

      trainee.course_education_phase&.upcase_first
    end

    def course_education_phase(course)
      course&.level&.capitalize
    end

    def course_study_mode(trainee)
      {
        "full_time" => "Full time",
        "part_time" => "Part time",
      }[trainee.study_mode]
    end

    def sanitise(value)
      return value unless value.is_a?(String)

      value.start_with?(*VULNERABLE_CHARACTERS) ? value.prepend("'") : value
    end

    def lead_school_name(trainee)
      trainee.lead_school_not_applicable? ? I18n.t(:not_applicable) : trainee.lead_school&.name
    end

    def employing_school_name(trainee)
      trainee.employing_school_not_applicable? ? I18n.t(:not_applicable) : trainee.employing_school&.name
    end
  end
end
