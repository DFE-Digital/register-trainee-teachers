# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  module ReviewSummary
    describe View, type: :component do
      let(:invalid_data_view) { instance_double(ApplyInvalidDataView, summary_content: "Some header content", summary_items_content: "", invalid_data?: true) }
      let(:trainee) { build(:trainee, :with_apply_application) }
      let(:described_component) { described_class.new(has_errors: true, trainee: trainee) }

      before do
        allow(ApplyInvalidDataView).to receive(:new).with(trainee.apply_application).and_return(invalid_data_view)
      end

      context "with has_errors set to true" do
        it "renders the given content in a ErrorSummary::View component" do
          expect(described_component.summary_component).to eq(ErrorSummary::View)
        end
      end

      context "with has_errors set to false" do
        let(:described_component) { described_class.new(has_errors: false, trainee: trainee) }

        it "renders the given content in a InformationSummary::View component" do
          expect(described_component.summary_component).to eq(InformationSummary::View)
        end
      end

      context "with header content" do
        before do
          render_inline(described_component)
        end

        it "renders the given content from the block" do
          expect(rendered_component).to have_selector("p", text: invalid_data_view.summary_content)
        end
      end
    end
  end
end
