# frozen_string_literal: true

module SystemAdmin
  # Validates a single step of the "Add relevant degrees" wizard. Built per page
  # from the session draft + the submitted answer; only the current step's rule
  # runs, so GOV.UK inline errors work natively.
  class RelevantDegreeStepForm
    include ActiveModel::Model

    def self.model_name = ActiveModel::Name.new(self, nil, "relevant_degree_step_form")

    attr_accessor :step, :academic_year, :allocation_subject_id, :allocation_subject_id_raw,
                  :cah_level_1_code, :cah_level_2_code, :hecos_codes

    validate :validate_current_step

    def academic_cycle
      return if academic_year.blank?

      AcademicCycle.for_year(academic_year.to_i)
    end

    def selected_hecos = Array(hecos_codes).compact_blank

  private

    def validate_current_step
      method = "validate_#{step}"
      send(method) if respond_to?(method, true)
    end

    def validate_academic_year
      if academic_year.blank?
        errors.add(:academic_year, "Select an academic year")
      elsif academic_cycle.nil?
        errors.add(:academic_year, "Select a valid academic year")
      elsif academic_cycle.funding_locked?
        errors.add(:academic_year, "You cannot change relevant degrees for a year that is live or has ended")
      end
    end

    def validate_subject
      errors.add(:allocation_subject_id, "Select an ITT subject") unless AllocationSubject.exists?(id: allocation_subject_id)
    end

    def validate_cah_level_1
      errors.add(:cah_level_1_code, "Select a CAH level 1 category") unless ::Funding::CahReference.valid_level_1?(cah_level_1_code)
    end

    def validate_cah_level_2
      errors.add(:cah_level_2_code, "Select a CAH level 2 category") unless ::Funding::CahReference.valid_level_2?(cah_level_1_code, cah_level_2_code)
    end

    def validate_hecos
      if selected_hecos.empty?
        errors.add(:hecos_codes, "Select at least one HECoS code")
      elsif cah_level_2_code.present? && (selected_hecos - ::Funding::CahReference.hecos_codes_for(cah_level_2_code)).any?
        errors.add(:hecos_codes, "Select HECoS codes that belong to the chosen CAH level 2 category")
      end
    end
  end
end
