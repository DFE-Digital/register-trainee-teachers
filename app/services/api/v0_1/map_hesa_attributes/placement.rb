# frozen_string_literal: true

module Api
  module V01
    module MapHesaAttributes
      class Placement
        ATTRIBUTES = %i[school_urn].freeze

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
          urn = @params[:urn]
          return if urn.blank?

          school = School.find_by(urn:)
          return if school.blank?

          school.id
        end

        def urn
          urn = @params[:urn]
          return if school_urn_applicable?(urn)

          urn
        end

        def name
          urn = @params[:urn]
          return if school_urn_applicable?(urn)

          I18n.t("components.placement_detail.magic_urn.#{urn}")
        end

        def school_urn_applicable?(urn)
          ::Api::V01::MapHesaAttributes::NOT_APPLICABLE_SCHOOL_URNS.exclude?(urn)
        end
      end
    end
  end
end
