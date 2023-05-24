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
          schools.find_each do |school|
            placement = trainee.placements.new(school:)

            placement.save!
          end
        else
          hesa_urns.each do |hesa_urn|
            next if Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.exclude?(hesa_urn)

            placement = trainee.placements.new(
              {
                urn: hesa_urn,
                name: I18n.t("components.placement_detail.magic_urn.#{hesa_urn}"),
              },
            )
            placement.save!
          end
        end
      end
    end
  end
end
