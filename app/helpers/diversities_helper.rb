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

  def back_link(trainee)
    if trainee.ethnic_group.blank? || trainee.ethnic_background.blank?
      edit_trainee_diversity_ethnic_group_path(trainee)
    else
      edit_trainee_diversity_ethnic_background_path(trainee)
    end
  end
end
