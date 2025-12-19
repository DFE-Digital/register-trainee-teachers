# frozen_string_literal: true

require "rails_helper"

describe TraineePersonalDetails::View do
  let(:trainee) { create(:trainee) }
  let(:policy) { instance_double(TraineePolicy, update?: true) }

  subject(:component) { described_class.new(trainee:, current_user:) }

  before do
    allow(TraineePolicy).to receive(:new).and_return(policy)
  end

  context "with a training partner user" do
    let(:current_user) do
      UserWithOrganisationContext.new(
        user: create(:user, :with_training_partner_organisation), session: {},
      )
    end

    before do
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
      it "doesn't display sex or nationality" do
        expect(rendered_content).not_to have_text("Sex")
        expect(rendered_content).not_to have_text("Nationality")
      end

      it "doesn't display diversity information" do
        expect(rendered_content).not_to have_text("Diversity")
      end
    end
  end
end
