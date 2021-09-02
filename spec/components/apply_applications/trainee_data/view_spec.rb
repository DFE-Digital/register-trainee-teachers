# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  module TraineeData
    describe View do
      alias_method :component, :page

      let(:apply_application) { create(:apply_application) }

      before do
        render_inline(View.new(trainee))
      end

      context "trainee with degrees" do
        let(:degree) { build(:degree, :uk_degree_with_details) }
        let(:trainee) do
          create(:trainee, nationalities: [build(:nationality)], degrees: [degree], apply_application: apply_application)
        end

        it "has an expanded degrees section" do
          expect(component).to have_text(degree.subject)
        end
      end

      context "draft apply trainee without degrees" do
        let(:trainee) do
          create(:trainee, nationalities: [build(:nationality)], degrees: [], apply_application: apply_application)
        end

        it "has a collapsed degrees section" do
          expect(component).to have_text("Degree details not provided")
        end
      end

      context "apply trainee without invalid data" do
        let(:apply_application) { create(:apply_application) }
        let(:trainee) do
          create(:trainee, nationalities: [build(:nationality)], degrees: [], apply_application: apply_application)
        end

        it "does not render the information summary component" do
          expect(component).not_to have_text("is not recognised")
          expect(component).not_to have_text("This application contains")
        end
      end
    end
  end
end
