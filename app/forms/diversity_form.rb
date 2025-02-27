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

  def ethnic_group_provided?
    !not_provided_ethnic_group?
  end

  def save!
    diversity_forms.each(&:save!)
  end

  def missing_fields
    [
      diversity_forms.flat_map do |diversity_form|
        diversity_form.valid?
        diversity_form.errors.attribute_names
      end,
    ]
  end

  def valid?
    diversity_forms.all?(&:valid?)
  end

  def errors
    diversity_forms.flat_map { |diversity_forms| diversity_forms.errors.to_a }
  end

  delegate :diversity_disclosure, :diversity_disclosed?, :diversity_not_disclosed?, to: :@disclosure_form

  delegate :disability_disclosure, :disabled?, :no_disability?, to: :@disability_disclosure_form

  delegate :disabilities, :additional_disability, to: :@disability_detail_form

  delegate :ethnic_group, :not_provided_ethnic_group?, to: :@ethnic_group_form

  delegate :ethnic_background, :additional_ethnic_background, to: :@ethnic_background_form
end
