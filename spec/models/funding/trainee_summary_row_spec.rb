# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryRow do
    describe "associations" do
      it { is_expected.to belong_to(:trainee_summary) }
      it { is_expected.to have_many(:amounts) }
    end

    describe "Lead School Migration" do
      it "includes the LeadSchoolMigratable concern" do
        expect(described_class.included_modules).to include(LeadSchoolMigratable)
      end

      it "calls set_lead_columns with the correct arguments" do
        expect(described_class.lead_school_column).to eq(:lead_school_urn)
        expect(described_class.lead_partner_column).to eq(:lead_partner_urn)
      end
    end

    describe "#route_type" do
      it do
        expect(subject).to define_enum_for(:route_type)
          .with_values(
            school_direct_salaried: "school_direct_salaried",
            pg_teaching_apprenticeship: "pg_teaching_apprenticeship",
            early_years_postgrad: "early_years_postgrad",
            early_years_salaried: "early_years_salaried",
            provider_led: "provider_led",
            opt_in_undergrad: "opt_in_undergrad",
            school_direct_tuition_fee: "school_direct_tuition_fee"
          )
          .backed_by_column_of_type(:string)
      end
    end

    describe "#route" do
      let(:trainee_summary) { create(:trainee_summary, :for_provider) }

      context "when route_type is nil" do
        let(:route) { "Provider-led" }
        let(:trainee_summary_row) { create(:trainee_summary_row, route_type: nil, trainee_summary:) }

        it "returns super" do
          expect(trainee_summary_row.route). to eq("Provider-led")
        end
      end

      context "when route_type is not nil" do
          %i[
            school_direct_salaried
            school_direct_tuition_fee
            pg_teaching_apprenticeship
            early_years_postgrad
            early_years_salaried
            provider_led
            opt_in_undergrad
          ].each do |route_type|
            it "returns the ITT translation" do
              trainee_summary_row = create(:trainee_summary_row, route_type:, trainee_summary:)

              expect(trainee_summary_row.route).to eq(
                I18n.t("activerecord.attributes.trainee.training_routes.itt.#{route_type}")
              )
            end
          end
      end
    end
  end
end
