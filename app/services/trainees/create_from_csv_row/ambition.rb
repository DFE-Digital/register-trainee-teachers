# frozen_string_literal: true

module Trainees
  module CreateFromCsvRow
    class Ambition < Base
      def initialize(csv_row:)
        @csv_row = csv_row
        @provider = Provider.find_by!(code: "1TF")
        @trainee = @provider.trainees.find_or_initialize_by(provider_trainee_id: lookup("Provider trainee ID"))
      end

    private

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

      def mapped_attributes
        {
          record_source: Trainee::MANUAL_SOURCE,
          region: lookup("Region"),
          training_route: training_route,
          first_names: lookup("First names"),
          middle_names: lookup("Middle names"),
          last_name: lookup("Last names"),
          sex: sex,
          date_of_birth: Date.parse(lookup("Date of birth")),
          nationality_ids: nationality_ids,
          email: lookup("Email"),
          training_initiative: training_initiative,
          employing_school_id: employing_school_id,
          lead_partner_id: lead_partner_id,
          deferal_date: deferal_date,
        }.merge(ethnicity_and_disability_attributes)
         .merge(course_attributes)
         .merge(funding_attributes)
      end

      def training_route
        case_insensitive_lookup(TRAINING_ROUTES, lookup("Training Route"))
      end

      def training_initiative
        case_insensitive_lookup(INITIATIVES, lookup("Training Initiative one"))
      end

      # NOTE: the CSV template seems to offer both URN or UKPRN but School only has URN
      def employing_school_id
        School.find_by(urn: lookup("Employing school URN or UKPRN"))&.id
      end

      def lead_partner_id
        LeadPartner.find_by_ukprn_or_urn(lookup("Lead Partner URN or UKPRN")&.strip)&.id
      end

      def create_placements!
        [lookup("First Placement URN"), lookup("Second Placement URN")].compact.each do |urn|
          next unless (school = School.find_by(urn:))

          Placement.find_or_create_by(trainee:, school:)
        end
      end

      def deferal_date
        lookup("Defer Date")
      end
    end
  end
end
