# frozen_string_literal: true

require "govuk/components"

module RecordDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(trainee: mock_trainee("default"), last_updated_event: last_updated_event))
    end

    def with_region
      trainee = mock_trainee("default").tap do |t|
        t.region = Dttp::CodeSets::Regions::MAPPING.keys.sample
        t.provider = Provider.new(code: TEACH_FIRST_PROVIDER_CODE)
      end

      render(View.new(trainee: trainee, last_updated_event: last_updated_event))
    end

    def with_no_trainee_id
      render(View.new(trainee: mock_trainee(nil), last_updated_event: last_updated_event))
    end

    def with_deferred_status
      render(View.new(trainee: mock_trainee("deferred", :deferred), last_updated_event: last_updated_event))
    end

    def with_withdrawn_status
      render(View.new(trainee: mock_trainee("withdrawn", :withdrawn), last_updated_event: last_updated_event))
    end

    def with_qts_recommended
      render(View.new(trainee: mock_trainee("qts_recommended", :recommended_for_award), last_updated_event: last_updated_event))
    end

    def with_eyts_recommended
      trainee = mock_trainee("eyts_recommended", :recommended_for_award, TRAINING_ROUTE_ENUMS[:early_years_undergrad])
      render(View.new(trainee: trainee, last_updated_event: last_updated_event))
    end

    def with_qts_awarded
      render(View.new(trainee: mock_trainee("qts_awarded", :awarded), last_updated_event: last_updated_event))
    end

    def with_eyts_awarded
      trainee = mock_trainee("eyts_awarded", :awarded, TRAINING_ROUTE_ENUMS[:early_years_undergrad])
      render(View.new(trainee: trainee, last_updated_event: last_updated_event))
    end

  private

    def mock_trainee(trainee_id, state = :draft, training_route = TRAINING_ROUTE_ENUMS[:assessment_only])
      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: training_route,
        trainee_id: trainee_id,
        created_at: Time.zone.today,
        state: state,
        submitted_for_trn_at: Time.zone.today,
        trn: "1234567",
        defer_date: state == :deferred ? Time.zone.today : nil,
        withdraw_date: state == :withdrawn ? Time.zone.today : nil,
        recommended_for_award_at: state == :recommended_for_award ? Time.zone.now : nil,
        awarded_at: state == :awarded ? Time.zone.now : nil,
      )
    end

    def last_updated_event
      OpenStruct.new(date: Time.zone.today)
    end
  end
end
