# frozen_string_literal: true

require "rails_helper"

module ReviewSummary
  describe View, type: :component do
    let(:trainee) { build(:trainee, :with_apply_application) }
    let(:form) { instance_double(ApplyApplications::TraineeDataForm, errors: ["bad data"]) }
    let(:described_component) { described_class.new(form:, invalid_data_view:) }
    let(:trainee_data_form) { ApplyApplications::TraineeDataForm.new(trainee, include_degree_id: true) }

    let(:invalid_data_view) do
      instance_double(ApplyApplications::InvalidTraineeDataView, summary_content: "Some header content",
                                                                 summary_items_content: "",
                                                                 invalid_data?: true)
    end

    before do
      allow(ApplyApplications::InvalidTraineeDataView).to(
        receive(:new).with(trainee, trainee_data_form).and_return(invalid_data_view),
      )

      render_inline(described_component)
    end

    context "with an invalid form having errors initialised" do
      it "renders the given content in a ErrorSummary::View component" do
        expect(described_component.summary_component).to eq(ErrorSummary::View)
      end
    end

    context "with an invalid form, but without errors initialised" do
      let(:form) { instance_double(ApplyApplications::TraineeDataForm, errors: [], valid?: false) }

      it "renders the component" do
        expect(page).to have_text("Some header content")
      end

      it "renders the given content in a InformationSummary::View component" do
        expect(described_component.summary_component).to eq(InformationSummary::View)
      end
    end

    context "with header content" do
      it "renders the given content from the block" do
        expect(page).to have_selector("p", text: invalid_data_view.summary_content)
      end
    end

    context "when the form has no errors" do
      let(:form) { instance_double(ApplyApplications::TraineeDataForm, errors: []) }
      let(:invalid_data_view) { instance_double(ApplyApplications::InvalidTraineeDataView, invalid_data?: false) }

      it "does not render" do
        expect(page).not_to have_text("Some header content")
      end
    end
  end
end
