# frozen_string_literal: true

module Api
  class GetTraineesService < BaseService
    def initialize(provider:, params: {}, version:)
      super(params)

      @provider = provider
      @version = version
    end

    def call
      return [[], trainee_filter_params_attributes.errors] unless trainee_filter_params_attributes.valid?

      [
        ::Trainees::Filter.call(trainees:, filters:)
          .includes(%i[published_course employing_school training_partner placements degrees hesa_trainee_detail]),
        nil,
      ]
    end

  private

    attr_reader :provider, :version

    def trainees
      @trainees ||= provider.trainees
        .not_draft
        .joins(:start_academic_cycle)
        .includes(%i[nationalities withdrawal_reasons])
        .where(academic_cycles: { id: academic_cycle.id })
        .where(trainees: { updated_at: since.. })
        .order("trainees.updated_at #{sort_order}")
        .order("trainees.id DESC")
        .page(page)
        .per(pagination_per_page)
    end

    def trainee_filter_params
      @trainee_filter_params ||= Api::TraineeFilterParams.new(filter_params)
    end

    def academic_cycle
      @academic_cycle ||= AcademicCycle.for_year(params[:academic_cycle]) || AcademicCycle.current
    end

    def filters
      @filters ||= TraineeFilter.new(params:).filters
    end

    def filter_params
      params.permit(:status, :since, :academic_cycle, :has_trn, :page, :per_page, :sort_order)
    end

    def trainee_filter_params_attributes
      @trainee_filter_params_attributes ||= Api::GetVersionedItem.for_attributes(model: :trainee_filter_params, version: version).new(filter_params)
    end
  end
end
