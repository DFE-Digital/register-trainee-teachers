# frozen_string_literal: true

module Api
  class GetTraineesService < BaseService
    def initialize(provider:, params: {})
      super(params)
      @provider = provider
    end

    class TraineeFilterParams
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[status since academic_cycle].freeze
      ATTRIBUTES.each { |attr| attribute attr }

      validate :check_statuses
      validate :check_since
      validate :check_academic_cycle

    private

      def check_statuses
        return if status.blank?

        (status.is_a?(Array) ? status : [status]).each do |status_value|
          errors.add(:status, "#{status_value} is not a valid status") unless Trainee.states.include?(status_value)
        end
      end

      def check_since
        return if since.blank?

        date_since =
          begin
            Date.parse(since)
          rescue Date::Error
            nil
          end

        errors.add(:since, "#{since} is not a valid date") unless date_since
      end

      def check_academic_cycle
        return if academic_cycle.blank?

        unless AcademicCycle.for_year(academic_cycle)
          errors.add(
            :academic_cycle,
            "#{academic_cycle} is not a valid academic cycle year",
          )
        end
      end
    end

    def call
      trainee_filter_params = TraineeFilterParams.new(filter_params)
      return [[], trainee_filter_params.errors] unless trainee_filter_params.valid?

      trainees = provider.trainees
                .not_draft
                .joins(:start_academic_cycle)
                .where(academic_cycles: { id: academic_cycle.id })
                .where("trainees.updated_at > ?", since)
                .order("trainees.updated_at #{sort_by}")
                .page(page)
                .per(pagination_per_page)

      filtered_trainees = ::Trainees::Filter.call(trainees:, filters:)
      [filtered_trainees.includes(%i[published_course employing_school lead_school placements degrees hesa_trainee_detail]), nil]
    end

  private

    attr_reader :provider

    def academic_cycle
      @academic_cycle ||= AcademicCycle.for_year(params[:academic_cycle]) || AcademicCycle.current
    end

    def filters
      @filters ||= TraineeFilter.new(params:).filters
    end

    def filter_params
      params.permit(:status, :since, :academic_cycle)
    end
  end
end
