module Api
  module MapHesaAttributes
    module Placements
      class V01
        ATTRIBUTES = %i[school_urn placement_days].freeze

        def initialize(params)
          @params = params
        end

        def call
          mapped_params
        end

      private

        def mapped_params
          {
            school_id:,
            urn:,
            name:,
          }
        end

        def school_id
          school_urn = @params[:school_urn]
          return if school_urn.blank?

          school = School.find_by(urn: school_urn)
          return if school.blank?

          school.id
        end

        def urn
          school_urn = @params[:school_urn]
          return if school_urn_applicable?(school_urn)

          school_urn
        end

        def name
          school_urn = @params[:school_urn]
          return if school_urn_applicable?(school_urn)

          I18n.t("components.placement_detail.magic_urn.#{school_urn}")
        end

        def school_urn_applicable?(urn)
          Api::MapHesaAttributes::V01::NOT_APPLICABLE_SCHOOL_URNS.exclude?(urn)
        end
      end
    end
  end
end
