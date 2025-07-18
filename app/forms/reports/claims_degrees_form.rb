# frozen_string_literal: true

module Reports
  class ClaimsDegreesForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include DatesHelper

    attr_accessor :from_day, :from_month, :from_year, :to_day, :to_month, :to_year

    validate :from_date_required
    validate :to_date_required
    validate :from_date_valid
    validate :to_date_valid
    validate :date_range_logical, if: -> { from_date_parsed.is_a?(Date) && to_date_parsed.is_a?(Date) }
    validate :date_range_within_one_year, if: -> { from_date_parsed.is_a?(Date) && to_date_parsed.is_a?(Date) }
    validate :data_exists_for_period, if: -> { dates_are_valid? }

    def from_date_parsed
      return nil unless from_date_present?

      date_hash = { year: from_year, month: from_month, day: from_day }
      date_args = date_hash.values.map(&:to_i)

      valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
    end

    def to_date_parsed
      return nil unless to_date_present?

      date_hash = { year: to_year, month: to_month, day: to_day }
      date_args = date_hash.values.map(&:to_i)

      valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
    end

    def degrees_scope
      scope = Degree.includes(trainee: :hesa_trainee_detail).joins(:trainee).where.not(trainees: { trn: nil })

      if from_date_parsed.is_a?(Date)
        scope = scope.where(degrees: { created_at: from_date_parsed.beginning_of_day.. })
      end

      if to_date_parsed.is_a?(Date)
        scope = scope.where(degrees: { created_at: ..to_date_parsed.end_of_day })
      end

      scope.order(:trainee_id)
    end

  private

    def from_date_present?
      [from_day, from_month, from_year].any?(&:present?)
    end

    def to_date_present?
      [to_day, to_month, to_year].any?(&:present?)
    end

    def dates_are_valid?
      return false unless from_date_parsed.is_a?(Date) && to_date_parsed.is_a?(Date)
      return false if to_date_parsed < from_date_parsed
      return false if (to_date_parsed - from_date_parsed).to_i > 365

      true
    end

    def from_date_required
      unless from_date_present?
        errors.add(:from_date, "Enter a from date")
      end
    end

    def to_date_required
      unless to_date_present?
        errors.add(:to_date, "Enter a to date")
      end
    end

    def from_date_valid
      unless from_date_parsed.is_a?(Date)
        errors.add(:from_date, "Enter a valid from date")
      end
    end

    def to_date_valid
      unless to_date_parsed.is_a?(Date)
        errors.add(:to_date, "Enter a valid to date")
      end
    end

    def date_range_logical
      if to_date_parsed < from_date_parsed
        errors.add(:to_date, "To date must be after from date")
      end
    end

    def date_range_within_one_year
      if (to_date_parsed - from_date_parsed).to_i > 365
        errors.add(:to_date, "Date range cannot exceed 1 year")
      end
    end

    def data_exists_for_period
      if degrees_scope.empty?
        period_description = "between #{from_date_parsed.to_fs(:govuk)} and #{to_date_parsed.to_fs(:govuk)}"
        errors.add(:base, "No degree data found #{period_description}")
      end
    end
  end
end
