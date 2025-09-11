# frozen_string_literal: true

module Paginator
  class View < ApplicationComponent
    attr_reader :scope

    # This constant limits the number of links to pages rendered by #paginate.
    # In some cases, the number of links will be KAMINARI_LINKS_LIMIT + 1 because
    # kaminari refuses to leave a gap of just one number e.g. 1 ... 345 ... 9
    # so it renders 1 2 3 4 5 ... 9 instead.
    KAMINARI_LINKS_LIMIT = 5

    def initialize(scope:)
      @scope = scope
    end

    def render?
      scope.total_pages > 1
    end

    def page_start
      ((scope.current_page - 1) * scope.limit_value) + 1
    end

    def page_end
      [scope.current_page * scope.limit_value, total].min
    end

    def total
      scope.total_count
    end

    def paginate_configuration
      {
        window: numbers_each_side,
        left: numbers_left,
        right: numbers_right,
      }
    end

  private

    def total_pages_exceed_limit?
      scope.total_pages > KAMINARI_LINKS_LIMIT
    end

    def numbers_each_side
      return 4 unless total_pages_exceed_limit?

      if scope.current_page.between?(KAMINARI_LINKS_LIMIT - 1, scope.total_pages - (KAMINARI_LINKS_LIMIT - 2))

        ((KAMINARI_LINKS_LIMIT - 2).to_f / 2).floor
      else
        0
      end
    end

    def numbers_left
      return 0 unless total_pages_exceed_limit?

      if scope.current_page < (KAMINARI_LINKS_LIMIT - 1)
        KAMINARI_LINKS_LIMIT - 1
      else
        1
      end
    end

    def numbers_right
      return 0 unless total_pages_exceed_limit?

      if scope.current_page > scope.total_pages - (KAMINARI_LINKS_LIMIT - 2)
        KAMINARI_LINKS_LIMIT - 1
      else
        1
      end
    end
  end
end
