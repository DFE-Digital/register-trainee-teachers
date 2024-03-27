# frozen_string_literal: true

module Api
  class GetTraineesService < BaseService
    def initialize(provider:, params: {})
      super(params)
      @provider = provider
    end

    def call
      trainees = provider.trainees
                .not_draft
                .joins(:start_academic_cycle)
                .where(academic_cycles: { id: academic_cycle.id })
                .where("trainees.updated_at > ?", since)
                .order("trainees.updated_at #{sort_by}")
                .page(page)
                .per(pagination_per_page)

      filtered_trainees = ::Trainees::Filter.call(trainees:, filters:)
      filtered_trainees.includes(%i[published_course employing_school lead_school placements degrees hesa_trainee_detail])
    end

  private

    attr_reader :provider

    def academic_cycle
      @academic_cycle ||= AcademicCycle.for_year(params[:academic_cycle]) || AcademicCycle.current
    end

    def filters
      @filters ||= TraineeFilter.new(params:).filters
    end
  end
end
