require "rails_helper"

RSpec.describe Trainees::Confirmation::Degrees::View do
  alias_method :component, :page

  describe "UK Degrees" do
    context "when trainee has only one UK degree" do
      before(:all) do
        @result ||= render_inline(Trainees::Confirmation::Degrees::View.new(degrees: mock_single_uk_degree))
      end

      it "renders section title for the UK degree" do
        expected_title = "#{mock_single_uk_degree.first.uk_degree}: #{mock_single_uk_degree.first.degree_subject.downcase}"
        expect(component.find(".app-summary-card__title")).to have_text(expected_title)
      end

      it "renders degree type" do
        expect(component.find(".govuk-summary-list__row.degree-type")).to have_text(mock_single_uk_degree.first.uk_degree)
      end

      it "renders subject" do
        expect(component.find(".govuk-summary-list__row.subject")).to have_text(mock_single_uk_degree.first.degree_subject)
      end

      it "renders institution" do
        expect(component.find(".govuk-summary-list__row.institution")).to have_text(mock_single_uk_degree.first.institution)
      end

      it "renders graduation year" do
        expect(component.find(".govuk-summary-list__row.graduation-year")).to have_text(mock_single_uk_degree.first.graduation_year)
      end

      it "renders degree grade" do
        expect(component.find(".govuk-summary-list__row.grade")).to have_text(mock_single_uk_degree.first.degree_grade)
      end
    end

    context "when trainee has multiple UK degrees" do
      before(:all) do
        @result ||= render_inline(Trainees::Confirmation::Degrees::View.new(degrees: mock_multiple_uk_degrees))
      end

      it "renders a summary card for each degree" do
        expect(component.find_all(".app-summary-card").size).to eq(mock_multiple_uk_degrees.size)
      end
    end
  end

  describe "Non-UK Degrees" do
    context "when trainee has only one Non-UK degree" do
      before(:all) do
        @result ||= render_inline(Trainees::Confirmation::Degrees::View.new(degrees: mock_single_non_uk_degree))
      end

      it "renders section title for the UK degree" do
        expected_title = "Non-UK #{mock_single_non_uk_degree.first.non_uk_degree}: #{mock_single_non_uk_degree.first.degree_subject.downcase}"
        expect(component.find(".app-summary-card__title")).to have_text(expected_title)
      end

      it "renders degree type" do
        expect(component.find(".govuk-summary-list__row.comparable-uk-degree")).to have_text(mock_single_non_uk_degree.first.non_uk_degree)
      end

      it "renders subject" do
        expect(component.find(".govuk-summary-list__row.subject")).to have_text(mock_single_non_uk_degree.first.degree_subject)
      end

      it "renders country" do
        expect(component.find(".govuk-summary-list__row.country")).to have_text(mock_single_non_uk_degree.first.country)
      end

      it "renders graduation year" do
        expect(component.find(".govuk-summary-list__row.graduation-year")).to have_text(mock_single_non_uk_degree.first.graduation_year)
      end
    end

    context "when trainee has multiple Non-UK degrees" do
      before(:all) do
        @result ||= render_inline(Trainees::Confirmation::Degrees::View.new(degrees: mock_multiple_non_uk_degrees))
      end

      it "renders a summary card for each degree" do
        expect(component.find_all(".app-summary-card").size).to eq(mock_multiple_non_uk_degrees.size)
      end
    end
  end

private

  def mock_single_uk_degree
    @mock_single_uk_degree ||= [build(:degree, :uk_degree_with_details)]
  end

  def mock_multiple_uk_degrees
    @mock_multiple_uk_degrees ||= [
      build(:degree, :uk_degree_with_details),
      build(:degree, :uk_degree_with_details),
    ]
  end

  def mock_single_non_uk_degree
    @mock_single_non_uk_degree ||= [build(:degree, :non_uk_degree_with_details)]
  end

  def mock_multiple_non_uk_degrees
    @mock_multiple_non_uk_degrees ||= [
      build(:degree, :non_uk_degree_with_details),
      build(:degree, :non_uk_degree_with_details),
    ]
  end
end
