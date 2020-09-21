module Dttp
  class TraineePresenter
    attr_reader :trainee

    delegate_missing_to :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def to_dttp_params
      {
        "firstname" => trainee.first_names,
        "lastname" => trainee.last_name,
        "contactid" => trainee.dttp_id,
        "address1_line1" => trainee.address_line_one,
        "address1_line2" => trainee.address_line_two,
        "address1_line3" => trainee.town_city,
        "address1_postalcode" => trainee.postcode,
        "birthdate" => formatted_dob,
        "emailaddress1" => trainee.email,
        "gendercode" => trainee.gender,
        "mobilephone" => trainee.phone_number,
      }
    end

  private

    def formatted_dob
      trainee.date_of_birth.strftime("%d/%m/%Y")
    end
  end
end
