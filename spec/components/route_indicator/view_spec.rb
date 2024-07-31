# frozen_string_literal: true

require "rails_helper"

describe RouteIndicator::View do
  alias_method :component, :page

  let(:trainee) { create(:trainee) }

  before do
    render_inline(described_class.new(trainee:))
  end

  describe "rendered component" do
    it "renders the correct training route link" do
      expect(component).to have_link(href: "/trainees/#{trainee.slug}/training-routes/edit")
    end
  end

  describe "no rendered component" do
    let(:trainee) { create(:trainee, :submitted_for_trn) }

    it "wont render if the trainee is not a draft trainee" do
      expect(component).not_to have_content("recruited to")
    end
  end

  describe "apply application" do
    let(:trainee) { create(:trainee, :with_apply_application, :with_publish_course_details) }

    it "renders" do
      expect(component).to have_content(trainee.course_subject_one.upcase_first)
    end

    it "renders the correct training route link" do
      expect(component).to have_link(href: "/trainees/#{trainee.slug}/training-routes/edit")
    end

    context "with course details set" do
      let(:trainee) do
        create(:trainee, :with_apply_application, course_uuid: nil) do |trainee|
          create(:course, name: "Citizenship", uuid: ApiStubs::RecruitsApi.course[:course_uuid], code: ApiStubs::RecruitsApi.course[:course_code], provider: trainee.apply_application.provider)
        end
      end

      it "renders the apply application's course code" do
        expect(component).to have_content("Citizenship (V6X1)")
        expect(component).to have_content("Assessment only route.")
        expect(component).to have_content("recruited to")
      end
    end

    context "with course details not set" do
      let(:trainee) { create(:trainee, :with_apply_application) }

      it "does not render course details" do
        expect(component).not_to have_content("recruited to")
        expect(component).not_to have_content("Citizenship (V6X1)")
      end
    end
  end
end
