# frozen_string_literal: true

module DiversitiesHelper
  def format_ethnic_group_options(options)
    options.reject { |option| option == Diversities::ETHNIC_GROUP_ENUMS[:not_provided] }
  end

  def other_ethnic_background_option?(ethnic_background)
    ethnic_background.include?("Another") && ethnic_background.include?("background")
  end

  def format_disability_disclosure_options(options)
    options.reject { |option| option == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }
  end

  def diversity_confirm_path(trainee)
    diversity_form = DiversityForm.new(trainee)

    return trainee_diversity_confirm_path(trainee) unless diversity_form.diversity_disclosed?

    if diversity_form.ethnic_group.nil?
      edit_trainee_diversity_ethnic_group_path(trainee)
    elsif diversity_form.ethnic_group_provided? && diversity_form.ethnic_background.nil?
      edit_trainee_diversity_ethnic_background_path(trainee)
    elsif diversity_form.disability_disclosure.nil?
      edit_trainee_diversity_disability_disclosure_path(trainee)
    elsif diversity_form.disabilities.empty? && diversity_form.disabled?
      edit_trainee_diversity_disability_detail_path(trainee)
    else
      trainee_diversity_confirm_path(trainee)
    end
  end
end
