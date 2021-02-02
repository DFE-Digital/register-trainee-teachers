# frozen_string_literal: true

module ApplicationRecordCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render(ApplicationRecordCard::View.new(record: mock_trainee))
    end

    def multiple_cards
      render(ApplicationRecordCard::View.with_collection(mock_multiple_trainees))
    end

    def single_card_with_incomplete_data
      render(ApplicationRecordCard::View.new(record: Trainee.new(id: 1, created_at: Time.zone.now)))
    end

  private

    def mock_trainee
      Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tom", last_name: "Jones", record_type: "assessment_only", subject: "Primary")
    end

    def mock_multiple_trainees
      [Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tom", last_name: "Jones", record_type: "assessment_only", subject: "Primary"),
       Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Paddington", last_name: "Bear", record_type: "assessment_only", subject: "Science"),
       Trainee.new(id: 1, created_at: Time.zone.now),
       Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tim", last_name: "Knight", record_type: "assessment_only", subject: "Maths"),
       Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Toby", last_name: "Rocker")]
    end
  end
end
