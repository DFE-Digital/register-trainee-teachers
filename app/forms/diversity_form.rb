# frozen_string_literal: true

class DiversityForm
  attr_reader :trainee, :diversity_forms

  def initialize(trainee)
    @trainee = trainee

    @disclosure_form = Diversities::DisclosureForm.new(trainee)
    @ethnic_background_form = Diversities::EthnicBackgroundForm.new(trainee)
    @ethnic_group_form = Diversities::EthnicGroupForm.new(trainee)
    @disability_disclosure_form = Diversities::DisabilityDisclosureForm.new(trainee)
    @disability_detail_form = Diversities::DisabilityDetailForm.new(trainee)

    @diversity_forms = [
      @disclosure_form,
      @ethnic_background_form,
      @ethnic_group_form,
      @disability_disclosure_form,
      @disability_detail_form,
    ]
  end

  def diversity_disclosure
    @disclosure_form.diversity_disclosure
  end

  def diversity_disclosed?
    @disclosure_form.diversity_disclosed?
  end

  def diversity_not_disclosed?
    @disclosure_form.diversity_not_disclosed?
  end

  def disability_disclosure
    @disability_disclosure_form.disability_disclosure
  end

  def disabled?
    @disability_disclosure_form.disabled?
  end

  def no_disability?
    @disability_disclosure_form.no_disability?
  end

  def disabilities
    @disability_detail_form.disabilities
  end

  def additional_disability
    @disability_detail_form.additional_disability
  end

  def ethnic_group
    @ethnic_group_form.ethnic_group
  end

  def ethnic_group_provided?
    !@ethnic_group_form.not_provided_ethnic_group?
  end

  def ethnic_background
    @ethnic_background_form.ethnic_background
  end

  def additional_ethnic_background
    @ethnic_background_form.additional_ethnic_background
  end

  def save!
    diversity_forms.each(&:save!)
  end

  def missing_fields
    diversity_forms.flat_map do |diversity_form|
      diversity_form.valid?
      diversity_form.errors.attribute_names
    end
  end
end
