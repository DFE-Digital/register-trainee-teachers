# frozen_string_literal: true

require "rails_helper"

describe TraineePersonalDetails::View do
  let(:lead_school_user?) { false }
  let(:trainee) { create(:trainee) }
  let(:current_user) { create(:school) }
  let(:policy) { instance_double(TraineePolicy, update?: true) }

  subject(:component) { described_class.new(trainee:, current_user:) }

  before do
    allow(TraineePolicy).to receive(:new).and_return(policy)
    allow(current_user).to receive(:lead_school?).and_return(lead_school_user?)
    render_inline(component)
  end

  context "with a trainee with no degree" do
    it "renders the incomplete section component" do
      expect(rendered_content).to have_text("Add degree details")
    end
  end

  context "with a trainee with a degree" do
    let(:trainee) { create(:trainee, :in_progress) }

    it "renders the confirmation component" do
      expect(rendered_content).to have_text("Add another degree")
    end
  end

  context "minimal mode" do
    let(:lead_school_user?) { true }

    it "doesn't display sex or nationality" do
      expect(rendered_content).not_to have_text("Sex")
      expect(rendered_content).not_to have_text("Nationality")
    end

    it "doesn't display diversity information" do
      expect(rendered_content).not_to have_text("Diversity")
    end
  end
end
