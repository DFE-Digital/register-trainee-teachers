# frozen_string_literal: true

module TrainingPartnerResultNotice
  class ViewPreview < ViewComponent::Preview
    def with_one_remaining_record
      render(
        View.new(
          search_query: "oxf",
          search_limit: 15,
          search_count: 16,
        ),
      )
    end

    def with_multiple_remaining_records
      render(
        View.new(
          search_query: "oxf",
          search_limit: 15,
          search_count: 30,
        ),
      )
    end
  end
end
