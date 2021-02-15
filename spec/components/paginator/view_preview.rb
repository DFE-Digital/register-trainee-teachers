# frozen_string_literal: true

module Paginator
  class ViewPreview < ViewComponent::Preview
    def on_first_page_of_many
      render(Paginator::View.new(scope: scope))
    end

    def on_second_page_of_many
      render(Paginator::View.new(scope: scope(current_page: 2)))
    end

    def on_first_page_of_one
      render(Paginator::View.new(scope: scope(total_count: 24)))
    end

  private

    def scope(current_page: 1, total_count: 29, page_size: 25)
      OpenStruct.new(
        relation: Trainee.all.page(1),
        total_count: total_count,
        limit_value: page_size,
        current_page: current_page,
        total_pages: (total_count.to_f / page_size).ceil,
      )
    end

    def relation
      Trainee.all.page(1)
    end
  end
end
