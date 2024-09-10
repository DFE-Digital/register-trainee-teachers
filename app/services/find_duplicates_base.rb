# frozen_string_literal: true

module FindDuplicatesBase
  def potential_duplicates(provider)
    provider.trainees.not_withdrawn.or(provider.trainees.not_awarded)
      .includes([:start_academic_cycle])
      .where(date_of_birth:)
      .where("last_name ILIKE ?", last_name)
  end

  def confirmed_duplicate?(trainee)
    matching_recruitment_cycle_year?(trainee) &&
    matching_course_route?(trainee) &&
    at_least_one_match_identifying_attribute?(trainee)
  end

  def matching_recruitment_cycle_year?(trainee)
    trainee.start_academic_cycle&.start_date&.year == recruitment_cycle_year
  end

  def matching_course_route?(trainee)
    trainee.training_route == training_route
  end

  def at_least_one_match_identifying_attribute?(trainee)
    matching_first_name?(trainee) ||
      matching_email?(trainee)
  end

  def matching_first_name?(trainee)
    extract_first_name(trainee.first_names) == extract_first_name(first_names)
  end

  def matching_email?(trainee)
    normalise_name(trainee.email) == normalise_name(email)
  end

  def normalise_name(name)
    name&.strip&.downcase
  end

  def normalise_and_remove_punctuation(name)
    normalise_name(name)&.gsub(/[^a-z ]/, "")
  end

  def extract_first_name(names)
    normalise_and_remove_punctuation(names)&.partition(" ")&.first
  end
end
