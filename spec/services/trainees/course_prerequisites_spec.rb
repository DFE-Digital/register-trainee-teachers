# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CoursePrerequisites do
    let(:trainee) { build(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: nil) }

    it "needs the Level 5 declaration first on the EYTDA route" do
      expect(described_class.missing(trainee)).to eq([:level_five_declaration])
    end

    it "still needs it when answered but not marked complete" do
      trainee.level_five_qualification = true

      expect(described_class.missing(trainee)).to eq([:level_five_declaration])
    end

    it "needs nothing once it's complete" do
      trainee.level_five_qualification = false
      trainee.progress.level_five_declaration = true

      expect(described_class.missing(trainee)).to be_empty
    end

    it "needs nothing on other routes" do
      expect(described_class.missing(build(:trainee, :provider_led_postgrad))).to be_empty
    end
  end
end
