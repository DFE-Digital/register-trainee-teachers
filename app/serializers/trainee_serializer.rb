# frozen_string_literal: true

class TraineeSerializer
  def initialize(trainee)
    @trainee = trainee
  end

  def as_hash
    @trainee.attributes.merge(
      provider_attribues,
      diversity_attributes,
      course_attributes,
      school_attributes,
      nationality: nationality,
      placements: @trainee.placements.map(&:attributes),
      degrees: @trainee.degrees.map(&:attributes),
    )
  end

  def provider_attribues
    {
      ukprn: @trainee.provider&.ukprn,
    }
  end

  def diversity_attributes
    {
      ethnicity:,
      other_ethnicity:,
    }
  end

  def course_attributes
    {
      course_qualification:,
      course_level:,
      course_itt_subject:,
      course_education_phase:,
      course_study_mode:,
      course_itt_start_date:,
    }
  end

  def school_attributes
    {
      employing_school_urn:,
      lead_partner_urn_ukprn:,
    }
  end

  def nationality
    @trainee.nationalities.first&.name
  end

  def employing_school_urn
    @trainee.employing_school&.urn
  end

  def lead_partner_urn_ukprn
    @trainee.lead_school&.urn
  end

  def ethnicity
  end

  def other_ethnicity
  end

  def training_route
  end

  def course_qualification
  end

  def course_level
  end

  def course_itt_subject
  end

  def course_education_phase
  end

  def course_study_mode
  end

  def course_itt_start_date
  end
end
