# frozen_string_literal: true

require "rails_helper"

module PlacementDetails
  describe View do
    let(:trainee) { create(:trainee, :imported_from_hesa) }

    let(:hesa_student) do
      create(
        :hesa_student,
        collection_reference: "C22053",
        hesa_id: trainee.hesa_id,
        first_names: trainee.first_names,
        last_name: trainee.last_name,
        degrees: degrees,
        placements: placements,
      )
    end

    let!(:schools) { create_list(:school, 2) }

    let(:placements) do
      [{ "school_urn" => schools[0].urn }, { "school_urn" => schools[1].urn }]
    end

    let(:degrees) do
      [{ "graduation_date" => "2019-06-13", "degree_type" => "051", "subject" => "100318", "institution" => "0012", "grade" => "02", "country" => nil }]
    end

    before do
      trainee.hesa_students = [hesa_student]

      render_inline(View.new(trainee:))
    end

    it "shows the placement details" do
      schools.each do |school|
        expect(rendered_component).to have_text(school.name)
        expect(rendered_component).to have_text("URN #{school.urn}, #{school.town}, #{school.postcode}")
      end
    end

    Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.each do |magic_urn|
      context "when the placement details contain the magic URN #{magic_urn}" do
        let(:placements) do
          [{ "school_urn" => magic_urn }]
        end

        it "shows the placement details" do
          expect(rendered_component).to have_text(I18n.t("components.placement_detail.magic_urn.#{magic_urn}"))
        end
      end
    end
  end
end
