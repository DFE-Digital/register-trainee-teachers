# frozen_string_literal: true

require "rails_helper"

describe TrainingRouteManager do
  subject { described_class.new(trainee) }

  describe "#requires_lead_partner?" do
    %w[school_direct_tuition_fee school_direct_salaried teacher_degree_apprenticeship].each do |route|
      context "with the :routes_#{route} feature flag enabled", "feature_routes.#{route}": true do
        context "with a school direct trainee" do
          let(:trainee) { build(:trainee, route.to_sym) }

          it "returns true" do
            expect(subject.requires_lead_partner?).to be true
          end
        end

        context "with the :routes_#{route} feature flag disabled", "feature_routes.#{route}": false do
          context "with a non school direct trainee" do
            let(:trainee) { build(:trainee) }

            it "returns false" do
              expect(subject.requires_lead_partner?).to be false
            end
          end
        end
      end
    end
  end

  describe "#requires_employing_school?" do
    %w[school_direct_salaried pg_teaching_apprenticeship early_years_salaried teacher_degree_apprenticeship].each do |route|
      context "with the :routes_#{route} feature flag enabled", "feature_routes.#{route}": true do
        context "with a #{route} trainee" do
          let(:trainee) { build(:trainee, route) }

          it "returns true" do
            expect(subject.requires_employing_school?).to be true
          end
        end
      end

      context "with the :routes_#{route} feature flag disabled", "feature_routes.#{route}": false do
        let(:trainee) { build(:trainee, route) }

        it "returns false" do
          expect(subject.requires_employing_school?).to be false
        end
      end
    end

    %w[assessment_only early_years_postgrad early_years_assessment_only provider_led_postgrad opt_in_undergrad].each do |route|
      context "with the :routes_#{route} feature flag enabled", "feature_routes.#{route}": true do
        context "with a #{route} trainee" do
          let(:trainee) { build(:trainee, route) }

          it "returns false" do
            expect(subject.requires_employing_school?).to be false
          end
        end
      end
    end
  end

  describe "#requires_itt_start_date?" do
    context "with the :routes_pg_teaching_apprenticeship feature flag enabled", "feature_routes.pg_teaching_apprenticeship": true do
      context "with a pg teaching apprenticeship trainee" do
        let(:trainee) { build(:trainee, :pg_teaching_apprenticeship) }

        it "returns true" do
          expect(subject.requires_itt_start_date?).to be true
        end
      end

      context "with a non pg teaching apprenticeship trainee" do
        let(:trainee) { build(:trainee) }

        it "returns false" do
          expect(subject.requires_itt_start_date?).to be false
        end
      end
    end
  end

  describe "#requires_funding?", "feature_routes.iqts": true do
    context "with an iqts trainee" do
      let(:trainee) { build(:trainee, :iqts) }

      it "returns false" do
        expect(subject.requires_funding?).to be false
      end
    end

    context "with a non iqts trainee" do
      let(:trainee) { build(:trainee) }

      it "returns true" do
        expect(subject.requires_funding?).to be true
      end
    end
  end

  describe "#requires_iqts_country?", "feature_routes.iqts": true do
    context "with an iqts trainee" do
      let(:trainee) { build(:trainee, :iqts) }

      it "returns true" do
        expect(subject.requires_iqts_country?).to be true
      end
    end

    context "with a non iqts trainee" do
      let(:trainee) { build(:trainee) }

      it "returns false" do
        expect(subject.requires_iqts_country?).to be false
      end
    end
  end

  describe "#early_years_route?" do
    context "non early years route" do
      let(:trainee) { build(:trainee, :school_direct_salaried) }

      it "returns false" do
        expect(subject.early_years_route?).to be false
      end
    end

    context "early years route" do
      let(:trainee) { build(:trainee, :early_years_undergrad) }

      it "returns true" do
        expect(subject.early_years_route?).to be true
      end
    end
  end

  describe "#undergrad_route?" do
    context "non undergrad route" do
      let(:trainee) { build(:trainee, :school_direct_salaried) }

      it "returns false" do
        expect(subject.undergrad_route?).to be false
      end
    end

    %i[early_years_undergrad provider_led_undergrad opt_in_undergrad teacher_degree_apprenticeship].each do |route|
      context "undergrad route" do
        let(:trainee) { build(:trainee, route) }

        it "returns true" do
          expect(subject.undergrad_route?).to be true
        end
      end
    end
  end

  describe "#requires_study_mode?" do
    (TRAINING_ROUTES.keys - %w[early_years_assessment_only assessment_only]).each do |route|
      context "for route #{route}" do
        let(:trainee) { Struct.new(:training_route).new(route.to_s) }

        it "returns true" do
          expect(subject.requires_study_mode?).to be true
        end
      end
    end

    %w[early_years_assessment_only assessment_only].each do |route|
      context "for route #{route}" do
        let(:trainee) { create(:trainee, route) }

        it "returns false" do
          expect(subject.requires_study_mode?).to be false
        end
      end
    end
  end

  describe "#requires_placements?" do
    (TRAINING_ROUTES.keys - %w[early_years_assessment_only assessment_only]).each do |route|
      context "for route #{route}" do
        let(:trainee) { Struct.new(:training_route).new(route.to_s) }

        it "returns true" do
          expect(subject.requires_placements?).to be true
        end
      end
    end

    %w[early_years_assessment_only assessment_only].each do |route|
      context "for route #{route}" do
        let(:trainee) { create(:trainee, route) }

        it "returns false" do
          expect(subject.requires_placements?).to be false
        end
      end
    end
  end
end
