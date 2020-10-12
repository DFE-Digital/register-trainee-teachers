require "govuk/components"
class Trainees::Confirmation::ContactDetails::ViewPreview < ViewComponent::Preview
  def default_with_uk_address
    mock_trainee.locale_code = 'uk'

    render_component(Trainees::Confirmation::ContactDetails::View.new(trainee: mock_trainee))
  end

  def default_with_non_uk_address
    mock_trainee.locale_code = 'non_uk'

    render_component(Trainees::Confirmation::ContactDetails::View.new(trainee: mock_trainee))
  end


  private

  def mock_trainee
    @mock_trainee ||= Trainee.new(id: 1,
                                 address_line_one: "32 Windsor Gardens",
                                 address_line_two: "Westminster",
                                 town_city: "London",
                                 postcode: 'EC1 9CP',
                                 phone_number: '0207 123 4567',
                                 email: "Paddington@bear.com"
    )
  end
end
