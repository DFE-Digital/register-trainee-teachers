# frozen_string_literal: true

require "rails_helper"

describe LevelFiveDeclarationForm, type: :model do
  let(:trainee) { create(:trainee, :early_years_teacher_degree_apprenticeship) }

  subject(:form) { described_class.new(trainee, params:) }

  context "when the trainee holds a level 5 qualification" do
    let(:params) { { level_five_qualification: "true" } }

    it "saves yes" do
      expect(form.save!).to be_truthy
      expect(trainee.reload.level_five_qualification).to be(true)
    end
  end

  context "when they don't" do
    let(:params) { { level_five_qualification: "false" } }

    it "saves no" do
      expect(form.save!).to be_truthy
      expect(trainee.reload.level_five_qualification).to be(false)
    end
  end

  context "when nothing is chosen" do
    let(:params) { { level_five_qualification: nil } }

    it "asks for an answer" do
      expect(form).not_to be_valid
      expect(form.errors[:level_five_qualification]).to eq(["Select yes if the trainee holds a level 5 qualification"])
    end
  end
end
