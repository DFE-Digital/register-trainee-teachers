# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CoursePrerequisites do
    it "doesn't need the Level 5 declaration first on the EYTDA route" do
      trainee = build(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: nil)

      expect(described_class.missing(trainee)).to be_empty
    end

    it "needs nothing on other routes" do
      expect(described_class.missing(build(:trainee, :provider_led_postgrad))).to be_empty
    end
  end
end
