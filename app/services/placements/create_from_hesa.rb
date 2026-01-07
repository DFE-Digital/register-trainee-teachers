# frozen_string_literal: true

module Placements
  class CreateFromHesa
    include ServicePattern

    def initialize(trainee:, hesa_placements:)
      @trainee = trainee
      @hesa_placements = hesa_placements
    end

    def call
      create_placements!
    end

  private

    attr_reader :hesa_placements, :trainee

    def create_placements!
      trainee.transaction do
        trainee.placements.destroy_all
        hesa_urns = hesa_placements.map { |placement| placement[:school_urn] }
        schools = School.where(urn: hesa_urns)
        if schools.present?
          link_schools(schools)
        else
          handle_not_applicable_urns(hesa_urns)
        end
      end
    end

    def link_schools(schools)
      schools.find_each do |school|
        trainee.placements.find_or_create_by(school:)
      end
    end

    def handle_not_applicable_urns(urns)
      urns.each do |urn|
        # Skip if the not applicable urns are not among Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS
        next if School::NOT_APPLICABLE_SCHOOL_URNS.exclude?(urn)

        trainee.placements.find_or_create_by(
          {
            urn: urn,
            name: I18n.t("components.placement_detail.magic_urn.#{urn}"),
          },
        )
      end
    end
  end
end
