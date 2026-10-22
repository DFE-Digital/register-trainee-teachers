# frozen_string_literal: true

module SystemAdmin
  # Builds a relevant-degree mapping from the CAH management add flow: an
  # academic year + ITT subject + CAH level 1 → level 2 → the applicable HECoS
  # codes underneath.
  class RelevantDegreeMappingForm
    include ActiveModel::Model

    def self.model_name = ActiveModel::Name.new(self, nil, "RelevantDegreeMappingForm")

    attr_accessor :academic_year, :allocation_subject_id, :cah_level_1_code,
                  :cah_level_2_code, :hecos_codes, :created_by
    attr_reader :created_mappings

    validate :validate_academic_year
    validate :validate_subject
    validate :validate_cah
    validate :validate_hecos
    validate :validate_not_duplicate

    def academic_cycle
      return if academic_year.blank?

      AcademicCycle.for_year(academic_year.to_i)
    end

    def selected_hecos = Array(hecos_codes).reject(&:blank?)

    # One record per selected HECoS code — each gets its own DRCAH reference.
    def save!
      return false unless valid?

      @created_mappings = ActiveRecord::Base.transaction do
        selected_hecos.map do |code|
          RelevantDegreeMapping.create!(
            academic_cycle:, allocation_subject_id:, cah_level_1_code:,
            cah_level_2_code:, hecos_code: code, created_by:,
          )
        end
      end
    end

  private

    def validate_academic_year
      if academic_cycle.nil?
        errors.add(:academic_year, "Select a valid academic year")
      elsif academic_cycle.funding_locked?
        errors.add(:academic_year, "You cannot change relevant degrees for a year that is live or has ended")
      end
    end

    def validate_subject
      errors.add(:allocation_subject_id, "Select an ITT subject") unless AllocationSubject.exists?(id: allocation_subject_id)
    end

    def validate_cah
      unless ::Funding::CahReference.valid_level_1?(cah_level_1_code)
        errors.add(:cah_level_1_code, "Select a CAH level 1 category")
        return
      end

      errors.add(:cah_level_2_code, "Select a CAH level 2 category") unless ::Funding::CahReference.valid_level_2?(cah_level_1_code, cah_level_2_code)
    end

    def validate_hecos
      if selected_hecos.empty?
        errors.add(:hecos_codes, "Select at least one HECoS code")
      elsif cah_level_2_code.present? && (selected_hecos - ::Funding::CahReference.hecos_codes_for(cah_level_2_code)).any?
        errors.add(:hecos_codes, "Select HECoS codes that belong to the chosen CAH level 2 category")
      end
    end

    def validate_not_duplicate
      return if academic_cycle.nil? || allocation_subject_id.blank? || selected_hecos.empty?

      existing = RelevantDegreeMapping.where(academic_cycle:, allocation_subject_id:, hecos_code: selected_hecos).pluck(:hecos_code)
      return if existing.empty?

      names = existing.map { |code| "#{::Funding::CahReference.hecos_name(code)} (#{code})" }
      errors.add(:base, "These HECoS codes are already recorded for this subject and year: #{names.join(', ')}. Remove them from your selection or delete the existing records.")
    end
  end
end
