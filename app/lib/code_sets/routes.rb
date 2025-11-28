# frozen_string_literal: true

module CodeSets
  module Routes
    MAPPING = {
      ReferenceData::TRAINING_ROUTES.assessment_only.name => { entity_id: "99f435d5-a626-e711-80c8-0050568902d3" },
      ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name => { entity_id: "6189922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.provider_led_undergrad.name => { entity_id: "6189922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.early_years_undergrad.name => { entity_id: "6b89922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.school_direct_tuition_fee.name => { entity_id: "6f89922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.school_direct_salaried.name => { entity_id: "7789922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.early_years_postgrad.name => { entity_id: "6789922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.early_years_assessment_only.name => { entity_id: "6589922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.pg_teaching_apprenticeship.name => { entity_id: "cf9154ee-5678-e811-80f6-005056ac45bb" },
      # DTTP recognise future_teaching_scholars as a route not an initiative, hence this 'odd' mapping.
      ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] => { entity_id: "e7b6efbc-8d96-ea11-a811-000d3ab55801" },
      ReferenceData::TRAINING_ROUTES.early_years_salaried.name => { entity_id: "6989922e-acc2-e611-80be-00155d010316" },
      ReferenceData::TRAINING_ROUTES.opt_in_undergrad.name => { entity_id: "51a5f96f-e122-e811-80ec-005056ac45bb" },
      ReferenceData::TRAINING_ROUTES.hpitt_postgrad.name => { entity_id: "7b89922e-acc2-e611-80be-00155d010316" },
    }.freeze

    INACTIVE_MAPPING = {
      # EYITT - School Direct (Early Years)
      ReferenceData::TRAINING_ROUTES.early_years_postgrad.name => { entity_id: "6d89922e-acc2-e611-80be-00155d010316" },
    }.freeze
  end
end
