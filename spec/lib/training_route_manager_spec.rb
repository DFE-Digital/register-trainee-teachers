# frozen_string_literal: true

require "rails_helper"

describe TrainingRouteManager do
  let(:training_route_manager) { described_class.new(trainee) }

  shared_context "route checks" do |method_name, training_route_enums_key, other_training_route|
    describe "##{method_name}" do
      subject do
        training_route_manager.public_send(method_name)
      end

      context "trainee on a #{training_route_enums_key} training route" do
        let(:trainee) { build(:trainee, training_route: training_route_enums_key) }

        it "returns true" do
          expect(subject).to be true
        end
      end

      context "trainee on a non #{training_route_enums_key} training route " do
        let(:trainee) { build(:trainee, other_training_route || :assessment_only) }

        it "returns false" do
          expect(subject).to be false
        end
      end
    end
  end

  shared_examples "enabled? checks" do |method_name, training_route_enums_key, other_training_route|
    describe "##{method_name}" do
      subject do
        training_route_manager.public_send(method_name)
      end

      context "with the :routes_#{training_route_enums_key} feature flag enabled", "feature_routes.#{training_route_enums_key}": true do
        context "trainee on a #{training_route_enums_key} training route" do
          let(:trainee) { build(:trainee, training_route: training_route_enums_key) }

          it "returns true" do
            expect(subject).to be true
          end
        end

        context "trainee on a non #{training_route_enums_key} training route " do
          let(:trainee) { build(:trainee, other_training_route || :assessment_only) }

          it "returns false" do
            expect(subject).to be false
          end
        end
      end

      context "with the :routes_#{training_route_enums_key} feature flag disabled", "feature_routes.#{training_route_enums_key}": false do
        context "trainee on a #{training_route_enums_key} training route" do
          let(:trainee) { build(:trainee, training_route: training_route_enums_key) }

          it "returns false" do
            expect(subject).to be false
          end
        end

        context "trainee on a non #{training_route_enums_key} training route " do
          let(:trainee) { build(:trainee, other_training_route || :assessment_only) }

          it "returns false" do
            expect(subject).to be false
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

  include_examples "enabled? checks", "requires_placement_details?", "provider_led_postgrad"
  include_examples "enabled? checks", "requires_schools?", "school_direct_salaried"
  include_examples "enabled? checks", "requires_schools?", "school_direct_tuition_fee"
  include_examples "enabled? checks", "requires_schools?", "pg_teaching_apprenticeship"
  include_examples "enabled? checks", "requires_employing_school?", "school_direct_salaried"
  include_examples "enabled? checks", "requires_employing_school?",
                   "pg_teaching_apprenticeship"

  include_examples "route checks", "early_years_route?", "early_years_assessment_only"
  include_examples "route checks", "early_years_route?", "early_years_postgrad"
  include_examples "route checks", "early_years_route?", "early_years_salaried"
  include_examples "route checks", "early_years_route?", "early_years_undergrad"

  include_examples "route checks", "itt_route?", "early_years_undergrad"
  include_examples "route checks", "itt_route?", "pg_teaching_apprenticeship"

  # NOTE: `no op`, these routes are not available in the database yet.
  # include_examples "enabled? checks", "itt_route?", "provider_led_undergrad"
  # include_examples "enabled? checks", "itt_route?", "opt_in_undergrad"
end
