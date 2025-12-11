# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryRow do
    describe "associations" do
      it { is_expected.to belong_to(:trainee_summary) }
      it { is_expected.to have_many(:amounts) }
    end

    describe "Lead School Migration" do
      let(:user) { create(:user) }
      let(:summary) { create(:trainee_summary, payable: user.providers.first) }
      let(:row) { create(:trainee_summary_row, trainee_summary: summary) }

      it "includes the LeadSchoolMigratable concern" do
        expect(described_class.included_modules).to include(LeadSchoolMigratable)
      end

      it "calls set_lead_columns with the correct arguments" do
        expect(described_class.lead_school_column).to eq(:lead_school_urn)
        expect(described_class.lead_partner_column).to eq(:training_partner_urn)
      end
    end

    describe "#training_route" do
      it do
        expect(subject).to define_enum_for(:training_route)
          .with_values(
            school_direct_salaried: "school_direct_salaried",
            pg_teaching_apprenticeship: "pg_teaching_apprenticeship",
            early_years_postgrad: "early_years_postgrad",
            early_years_salaried: "early_years_salaried",
            provider_led_postgrad: "provider_led_postgrad",
            provider_led_undergrad: "provider_led_undergrad",
            opt_in_undergrad: "opt_in_undergrad",
            school_direct_tuition_fee: "school_direct_tuition_fee",
            teacher_degree_apprenticeship: "teacher_degree_apprenticeship",
          )
          .backed_by_column_of_type(:string)
      end
    end

    describe "#route" do
      let(:trainee_summary) { create(:trainee_summary, :for_provider) }

      context "when training_route is nil" do
        let(:route) { "Provider-led" }
        let(:trainee_summary_row) { create(:trainee_summary_row, training_route: nil, trainee_summary: trainee_summary) }

        it "returns super" do
          expect(trainee_summary_row.route). to eq("Provider-led")
        end
      end

      context "when training_route is not nil" do
        %i[
          school_direct_salaried
          school_direct_tuition_fee
          pg_teaching_apprenticeship
          early_years_postgrad
          early_years_salaried
          provider_led_postgrad
          provider_led_undergrad
          opt_in_undergrad
        ].each do |training_route|
          it "returns the ITT translation" do
            trainee_summary_row = create(:trainee_summary_row, training_route:, trainee_summary:)

            expect(trainee_summary_row.route).to eq(
              I18n.t("activerecord.attributes.trainee.training_routes.itt.#{training_route}"),
            )
          end
        end
      end

      it "syncs the lead school name and lead partner name" do
        row = create(:trainee_summary_row, trainee_summary:)
        row.update(lead_school_name: "School")
        expect(row.lead_partner_name).to eq("School")
        row.update(lead_partner_name: "Partner")
        expect(row.lead_school_name).to eq("Partner")
      end
    end
  end
end
