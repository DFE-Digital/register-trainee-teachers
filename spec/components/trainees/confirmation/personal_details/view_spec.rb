require "rails_helper"

module Trainees
  module Confirmation
    module PersonalDetails
      describe View do
        alias_method :component, :page

        context "when data has not been provided" do
          let(:trainee) { build(:trainee, id: 1, first_names: nil, date_of_birth: nil, gender: nil) }

          before do
            render_inline(View.new(trainee: trainee))
          end

          it "renders blank rows for full name, date of birth, gender and nationality" do
            expect(component).to have_selector(".govuk-summary-list__row", count: 4)
          end

          it "tells the user that no data has been entered" do
            component.find_all(".govuk-summary-list__row").each do |row|
              expect(row.find(".govuk-summary-list__value")).to have_text(t("components.confirmation.not_provided"))
            end
          end
        end

        context "when data has been provided" do
          let(:trainee) { build(:trainee, id: 1) }

          before do
            allow(trainee).to receive(:nationalities).and_return([OpenStruct.new(name: "British")])
            render_inline(View.new(trainee: trainee))
          end

          it "renders the full name" do
            expected_name = "#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}".upcase

            expect(component.find(".govuk-summary-list__row.full-name .govuk-summary-list__value"))
              .to have_text(expected_name)
          end

          it "renders the date of birth" do
            expected_dob = trainee.date_of_birth.strftime("%-d %B %Y")

            expect(component.find(".govuk-summary-list__row.date-of-birth .govuk-summary-list__value"))
              .to have_text(expected_dob)
          end

          it "renders the gender" do
            expect(component.find(".govuk-summary-list__row.gender .govuk-summary-list__value"))
              .to have_text(trainee.gender.capitalize)
          end

          it "renders the nationality" do
            expect(component.find(".govuk-summary-list__row.nationality .govuk-summary-list__value"))
              .to have_text("British")
          end

          context "when multiple nationalities have been provided" do
            before do
              allow(trainee).to receive(:nationalities).and_return([OpenStruct.new(name: "British"), OpenStruct.new(name: "Irish")])
              render_inline(View.new(trainee: trainee))
            end

            it "renders a list of nationalities" do
              expect(component.find_all(".govuk-summary-list__row.nationality .govuk-list li").length).to eq(2)
            end

            it "renders in the order of first to last" do
              nationalities_list = component.find_all(".govuk-summary-list__row.nationality .govuk-list li")

              expect(nationalities_list.first.text).to eq("British")
              expect(nationalities_list.last.text).to eq("Irish")
            end
          end
        end
      end
    end
  end
end
