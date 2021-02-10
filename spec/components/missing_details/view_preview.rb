# frozen_string_literal: true

module MissingDetails
  class ViewPreview < ViewComponent::Preview
    def personal_details_not_started
      render MissingDetails::View.new(section: "personal_details", progress: nil, trainee: "Bob")
    end

    def personal_details_not_marked_as_complete
      render MissingDetails::View.new(section: "personal_details", progress: false, trainee: "John")
    end

    def contact_details_not_started
      render MissingDetails::View.new(section: "contact_details", progress: nil, trainee: "Jenny")
    end

    def contact_details_not_marked_as_complete
      render MissingDetails::View.new(section: "contact_details", progress: false, trainee: "Larry")
    end

    def diversity_information_not_started
      render MissingDetails::View.new(section: "diversity", progress: nil, trainee: "Daniel")
    end

    def diversity_information_not_marked_as_complete
      render MissingDetails::View.new(section: "diversity", progress: false, trainee: "Ayse")
    end

    def degree_details_not_started
      render MissingDetails::View.new(section: "degrees", progress: nil, trainee: "Phil")
    end

    def degree_details_not_marked_as_complete
      render MissingDetails::View.new(section: "degrees", progress: false, trainee: "Mustafa")
    end

    def programme_details_not_started
      render MissingDetails::View.new(section: "programme_details", progress: nil, trainee: "Abdul")
    end

    def programme_details_not_marked_as_complete
      render MissingDetails::View.new(section: "programme_details", progress: false, trainee: "Henry")
    end
  end
end
