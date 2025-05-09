# frozen_string_literal: true

module HasDiversityAttributes
  def ethnicity_and_disability_attributes
    ethnicity_attributes.merge(disability_attributes)
                        .merge({ diversity_disclosure: })
  end

  def ethnicity_attributes
    if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
      ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

      return {
        ethnic_group:,
        ethnic_background:,
      }
    end

    {
      ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
      ethnic_background: Diversities::NOT_PROVIDED,
    }
  end

  def disability_attributes
    if !disability_disclosed?
      return {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
      }
    end

    if disabilities == [Diversities::NO_KNOWN_DISABILITY]
      return {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
      }
    end

    {
      disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
      disabilities: disabilities.map { |disability| Disability.find_by(name: disability) }.compact,
    }
  end

  def diversity_disclosure
    if disability_disclosed? || ethnicity_disclosed?
      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    else
      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end
  end

  def disability_disclosed?
    disabilities.any? && disabilities != [Diversities::NOT_PROVIDED]
  end

  def ethnicity_disclosed?
    ethnic_background.present? && [Diversities::NOT_PROVIDED, Diversities::INFORMATION_REFUSED].exclude?(ethnic_background)
  end
end
