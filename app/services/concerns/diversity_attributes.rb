# frozen_string_literal: true

module DiversityAttributes
  MULTIPLE_DISABILITIES_TEXT = "HESA multiple disabilities"

  def add_multiple_disability_text!
    return unless disability == Diversities::MULTIPLE_DISABILITIES

    trainee.trainee_disabilities.last.update!(additional_disability: MULTIPLE_DISABILITIES_TEXT)
  end

  def ethnicity_and_disability_attributes
    ethnicity_attributes.merge(disability_attributes)
                        .merge({ diversity_disclosure: diversity_disclosure })
  end

  def disability_attributes
    if disability.blank? || disability == Diversities::NOT_PROVIDED
      return {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
      }
    end

    if disability == Diversities::NO_KNOWN_DISABILITY
      return {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
      }
    end

    if disability == Diversities::MULTIPLE_DISABILITIES
      return {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
        disabilities: Disability.where(name: ::Diversities::OTHER),
      }
    end

    {
      disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
      disabilities: Disability.where(name: disability),
    }
  end

  def ethnicity_attributes
    if Diversities::NOT_PROVIDED_ETHNICITIES.include?(ethnic_background)
      return {
        ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
        ethnic_background: Diversities::NOT_PROVIDED,
      }
    end

    if Diversities::WHITE_ETHNICITIES.include?(ethnic_background)
      return {
        ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:white],
        ethnic_background: Diversities::NOT_PROVIDED,
      }
    end

    if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
      ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

      return {
        ethnic_group: ethnic_group,
        ethnic_background: ethnic_background,
      }
    end

    {
      ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
      ethnic_background: Diversities::NOT_PROVIDED,
    }
  end

  def diversity_disclosure
    if disability.present? || ethnicity_disclosed?
      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    else
      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end
  end

  def ethnicity_disclosed?
    ethnic_background.present? && [Diversities::NOT_PROVIDED, Diversities::INFORMATION_REFUSED].exclude?(ethnic_background)
  end
end
