# frozen_string_literal: true

require "rails_helper"

module Trainees
  module ApplyTraineeData
    describe View do
      alias_method :component, :page

      before do
        form = ApplyTraineeDataForm.new(trainee: trainee)
        render_inline(View.new(trainee, form))
      end

      context "trainee with degrees" do
        let(:trainee) { create(:trainee, nationalities: [build(:nationality)], degrees: [build(:degree, :uk_degree_with_details)]) }

        it "has an education section" do
          expect(component).to have_text("Education")
        end
      end

      context "trainee without degrees" do
        let(:trainee) { create(:trainee, nationalities: [build(:nationality)], degrees: []) }

        it "does not have an education section" do
          expect(component).to_not have_text("Education")
        end
      end
    end
  end
end
