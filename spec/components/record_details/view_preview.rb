# frozen_string_literal: true

require "govuk/components"

module RecordDetails
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(trainee: mock_trainee("default"), last_updated_event: last_updated_event))
    end

    def with_region
      trainee = mock_trainee("default").tap do |t|
        t.region = CodeSets::Regions::MAPPING.keys.sample
        t.provider = Provider.new(code: Provider::TEACH_FIRST_PROVIDER_CODE)
      end

      render(View.new(trainee:, last_updated_event:))
    end

    def as_system_admin
      render(View.new(trainee: mock_trainee(nil), last_updated_event: last_updated_event, show_provider: true))
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
      trainee = mock_trainee("eyts_recommended", :recommended_for_award, ReferenceData::TRAINING_ROUTES.early_years_undergrad.name)
      render(View.new(trainee:, last_updated_event:))
    end

    def with_qts_awarded
      render(View.new(trainee: mock_trainee("qts_awarded", :awarded), last_updated_event: last_updated_event))
    end

    def with_eyts_awarded
      trainee = mock_trainee("eyts_awarded", :awarded, ReferenceData::TRAINING_ROUTES.early_years_undergrad.name)
      render(View.new(trainee:, last_updated_event:))
    end

    def with_itt_not_yet_started
      trainee = mock_trainee("eyts_awarded", :awarded, ReferenceData::TRAINING_ROUTES.early_years_undergrad.name, :itt_not_yet_started)
      render(View.new(trainee:, last_updated_event:))
    end

  private

    def mock_trainee(provider_trainee_id, state = :draft, training_route = ReferenceData::TRAINING_ROUTES.assessment_only.name, commencement_status = :itt_started_later)
      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: training_route,
        provider_trainee_id: provider_trainee_id,
        created_at: Time.zone.today,
        state: state,
        submitted_for_trn_at: Time.zone.today,
        trn: "1234567",
        defer_date: state == :deferred ? Time.zone.today : nil,
        withdraw_date: state == :withdrawn ? Time.zone.today : nil,
        recommended_for_award_at: state == :recommended_for_award ? Time.zone.now : nil,
        trainee_start_date: Time.zone.now,
        commencement_status: commencement_status,
        awarded_at: state == :awarded ? Time.zone.now : nil,
        provider: mock_provider,
      )
    end

    def mock_provider
      Provider.new(code: "B1T", name: "DfE University")
    end

    def last_updated_event
      OpenStruct.new(date: Time.zone.today)
    end
  end
end
