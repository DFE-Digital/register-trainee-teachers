# frozen_string_literal: true

module Trainees
  module CreateFromCsvRow
    class Ambition < Base
      TRAINING_ROUTES = {
        "Assessment only" => TRAINING_ROUTE_ENUMS[:assessment_only],
        "Early years assessment only" => TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
        "Early Years Postgraduate" => TRAINING_ROUTE_ENUMS[:early_years_postgrad],
        "Early Years Salaried" => TRAINING_ROUTE_ENUMS[:early_years_salaried],
        "Early years undergraduate" => TRAINING_ROUTE_ENUMS[:early_years_undergrad],
        "International Qualified Teacher Status (IQTS)" => TRAINING_ROUTE_ENUMS[:iqts],
        "Opt-In Undergraduate" => TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
        "Provider-Led Postgraduate" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        "Provider-Led Undergraduate" => TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
        "School Direct Tuition Fee" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "School Direct Salaried" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "Postgraduate Teaching Apprenticeship" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
        "High Potential Initial Teacher Training (HPITT) Postgraduate" => TRAINING_ROUTE_ENUMS[:hpitt_postgrad],
      }.freeze

      INITIATIVES = {
        "International Relocation Payment" => ROUTE_INITIATIVES_ENUMS[:international_relocation_payment],
        "Now Teach" => ROUTE_INITIATIVES_ENUMS[:now_teach],
        "Veteran Teaching Undergraduate Bursary" => ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary],
        "Not on a Training Initiative" => ROUTE_INITIATIVES_ENUMS[:no_initiative],
      }.freeze

      def initialize(csv_row:)
        @provider = Provider.find_by!(code: Provider::AMBITION_PROVIDER_CODE)
        super(csv_row:, provider:)
      end

    private

      def after_actions
        create_placements!
        super
      end

      def mapped_attributes
        default_attributes.merge({ defer_date: })
      end

      def training_route
        case_insensitive_lookup(TRAINING_ROUTES, lookup("Training Route"))
      end

      def training_initiative
        case_insensitive_lookup(INITIATIVES, lookup("Training Initiative one"))
      end

      def create_placements!
        [lookup("First Placement URN"), lookup("Second Placement URN")].compact.each do |urn|
          next unless (school = School.find_by(urn:))

          Placement.find_or_create_by!(trainee:, school:)
        end
      end

      def defer_date
        lookup("Defer Date")
      end
    end
  end
end
