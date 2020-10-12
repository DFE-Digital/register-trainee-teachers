require "govuk/components"
class Trainees::Confirmation::ContactDetails::ViewPreview < ViewComponent::Preview
  def default_with_uk_address
    mocked_trainee = Trainee.new(id: 1,
                                 locale_code: 'uk',
                                 address_line_one: "32 Windsor Gardens",
                                 address_line_two: "Westminster",
                                 town_city: "London",
                                 postcode: 'EC1 9CP',
                                 phone_number: '0207 123 4567',
                                 email: "Paddington@bear.com"
    )


    render_component(Trainees::Confirmation::ContactDetails::View.new(trainee: mocked_trainee))

  end

  def default_with_non_uk_address
    mocked_trainee = Trainee.new(id: 1,
                                 locale_code: 'uk',
                                 address_line_one: "32 Windsor Gardens",
                                 address_line_two: "Westminster",
                                 town_city: "London",
                                 postcode: 'EC1 9CP',
                                 phone_number: '0207 123 4567',
                                 email: "Paddington@bear.com"
    )


    render_component(Trainees::Confirmation::ContactDetails::View.new(trainee: mocked_trainee))

  end
end
