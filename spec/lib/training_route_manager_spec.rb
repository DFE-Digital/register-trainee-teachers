# frozen_string_literal: true

require "rails_helper"

describe TrainingRouteManager do
  subject { described_class.new(trainee) }

  describe "#requires_placement_details?" do
    context "with the :routes_provider_led_postgrad feature flag enabled", "feature_routes.provider_led_postgrad": true do
      context "with placement feature enabled", feature_placements: true do
        context "with a provider-led trainee" do
          let(:trainee) { build(:trainee, :provider_led_postgrad) }

          it "returns true" do
            expect(subject.requires_placement_details?).to be true
          end
        end

        context "with a non provider-led trainee" do
          let(:trainee) { build(:trainee) }

          it "returns false" do
            expect(subject.requires_placement_details?).to be false
          end
        end
      end

      context "with placement feature disabled", feature_placements: false do
        context "with a provider-led trainee" do
          let(:trainee) { build(:trainee, :provider_led_postgrad) }

          it "returns false" do
            expect(subject.requires_placement_details?).to be false
          end
        end

        context "with a non provider-led trainee" do
          let(:trainee) { build(:trainee) }

          it "returns false" do
            expect(subject.requires_placement_details?).to be false
          end
        end
      end
    end

    context "with the :routes_provider_led_postgrad feature flag disabled", "feature.routes_provider_led_postgrad": false do
      let(:trainee) { build(:trainee, :provider_led_postgrad) }

      it "returns false" do
        expect(subject.requires_placement_details?).to be false
      end
    end
  end

  describe "#requires_schools?" do
    %w[school_direct_tuition_fee school_direct_salaried].each do |route|
      context "with the :routes_#{route} feature flag enabled", "feature_routes.#{route}": true do
        context "with a school direct trainee" do
          let(:trainee) { build(:trainee, route.to_sym) }

          it "returns true" do
            expect(subject.requires_schools?).to be true
          end
        end

        context "with the :routes_#{route} feature flag disabled", "feature_routes.#{route}": false do
          context "with a non school direct trainee" do
            let(:trainee) { build(:trainee) }

            it "returns false" do
              expect(subject.requires_schools?).to be false
            end
          end
        end
      end
    end
  end

  describe "#requires_employing_school?" do
    context "with the :routes_school_direct_salaried feature flag enabled", "feature_routes.school_direct_salaried": true do
      context "with a school direct salaried trainee" do
        let(:trainee) { build(:trainee, :school_direct_salaried) }

        it "returns true" do
          expect(subject.requires_employing_school?).to be true
        end
      end

      context "with a non school direct trainee" do
        let(:trainee) { build(:trainee) }

        it "returns false" do
          expect(subject.requires_employing_school?).to be false
        end
      end
    end

    context "with the :routes_school_direct_salaried feature flag disabled", "feature_routes.school_direct_salaried": false do
      let(:trainee) { build(:trainee) }

      it "returns false" do
        expect(subject.requires_employing_school?).to be false
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

  describe "#itt_route?" do
    %i[early_years_undergrad pg_teaching_apprenticeship].each do |route|
      context "with an itt trainee" do
        let(:trainee) { build(:trainee, route) }

        it "returns true" do
          expect(subject.itt_route?).to be true
        end
      end

      context "with the :routes_#{route} feature flag disabled", "feature_routes.#{route}": false do
        context "with a non itt trainee" do
          let(:trainee) { build(:trainee) }

          it "returns false" do
            expect(subject.itt_route?).to be false
          end
        end
      end
    end
  end

  context "with the :course_study_mode feature flag enabled", feature_course_study_mode: true do
    describe "#requires_study_mode?" do
      {
        assessment_only: false,
        early_years_assessment_only: false,
        early_years_postgrad: false,
        early_years_salaried: false,
        early_years_undergrad: false,
        pg_teaching_apprenticeship: false,
        opt_in_undergrad: false,

        provider_led_postgrad: true,
        school_direct_tuition_fee: true,
        school_direct_salaried: true,
        provider_led_undergrad: true,
        hpitt_postgrad: false,
      }.each do |route, return_val|
        context "route #{route}" do
          let(:trainee) { Struct.new(:training_route).new(route.to_s) }

          it "returns #{return_val}" do
            expect(subject.requires_study_mode?).to be(return_val)
          end
        end
      end
    end
  end
end
