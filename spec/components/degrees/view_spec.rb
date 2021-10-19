# frozen_string_literal: true

require "rails_helper"

RSpec.describe Degrees::View do
  before do
    render_inline(Degrees::View.new(data_model: trainee))
  end

  let(:trainee) do
    mock_trainee_with_single_uk_degree
  end

  let(:degree) do
    trainee.degrees.first
  end

  summary_list_row = "summary list row"

  shared_examples summary_list_row do |degree_attribute, field_name|
    it "renders row #{field_name}" do
      expect(rendered_component).to have_text(degree.public_send(degree_attribute))
    end

    it "has change link for #{field_name}" do
      expect(rendered_component).to have_link("Change #{field_name}")
    end
  end

  describe "UK Degrees" do
    context "when trainee has only one UK degree" do
      it "renders section title for the UK degree" do
        expected_title = "#{degree.uk_degree}: #{degree.subject.downcase}"
        expect(rendered_component).to have_text(expected_title)
      end

      it_behaves_like summary_list_row, :uk_degree, "degree type"
      it_behaves_like summary_list_row, :subject, "subject"
      it_behaves_like summary_list_row, :institution, "awarding institution"
      it_behaves_like summary_list_row, :graduation_year, "graduation year"
      it_behaves_like summary_list_row, :grade, "grade"
    end

    context "when trainee has multiple UK degrees" do
      let(:trainee) do
        mock_trainee_with_multiple_uk_degrees
      end

      it "renders a summary card for each degree" do
        expect(rendered_component).to have_selector(".app-summary-card", count: trainee.degrees.size)
      end
    end
  end

  describe "Non-UK Degrees" do
    context "when trainee has only one Non-UK degree" do
      let(:trainee) do
        mock_trainee_with_single_non_uk_degree
      end

      it "renders section title for the UK degree" do
        expected_title = "Non-UK #{degree.non_uk_degree}: #{degree.subject.downcase}"
        expect(rendered_component).to have_text(expected_title)
      end

      it_behaves_like summary_list_row, :subject, "subject"
      it_behaves_like summary_list_row, :country, "country"
      it_behaves_like summary_list_row, :graduation_year, "graduation year"
      it_behaves_like summary_list_row, :non_uk_degree, "degree type"
    end

    context "when trainee has multiple Non-UK degrees" do
      let(:trainee) do
        mock_trainee_with_multiple_non_uk_degrees
      end

      it "renders a summary card for each degree" do
        expect(rendered_component).to have_selector(".app-summary-card", count: trainee.degrees.size)
      end
    end
  end

  describe "Degree button text" do
    context "when there are degrees" do
      it "renders 'Add another degree' button" do
        expect(rendered_component).to have_text(t("components.degrees.add_another_degree"))
      end
    end

    context "suppress the 'Add another degree' button" do
      before do
        render_inline(Degrees::View.new(data_model: trainee, show_add_another_degree_button: false))
      end

      it "does not render 'Add another degree' button" do
        expect(rendered_component).not_to have_css(degree_button_selector)
      end
    end
  end

private

  def mock_trainee_with_single_uk_degree
    @mock_trainee_with_single_uk_degree ||= create(:trainee, degrees: [build(:degree, :uk_degree_with_details)])
  end

  def mock_trainee_with_multiple_uk_degrees
    @mock_trainee_with_multiple_uk_degrees ||= create(:trainee, degrees: [
      build(:degree, :uk_degree_with_details),
      build(:degree, :uk_degree_with_details),
    ])
  end

  def mock_trainee_with_single_non_uk_degree
    @mock_trainee_with_single_non_uk_degree ||= create(:trainee, degrees: [build(:degree, :non_uk_degree_with_details)])
  end

  def mock_trainee_with_multiple_non_uk_degrees
    @mock_trainee_with_multiple_non_uk_degrees ||= create(:trainee, degrees: [
      build(:degree, :non_uk_degree_with_details),
      build(:degree, :non_uk_degree_with_details),
    ])
  end

  def degree_button_selector
    ".govuk-button.govuk-button--secondary"
  end
end
