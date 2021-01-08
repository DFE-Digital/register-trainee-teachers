require_relative "config/environment"
require "factory_bot_rails"
require "faker"

FactoryBot.find_definitions rescue nil

user = FactoryBot.build(:user, dttp_id: "98c63edb-b0a6-e811-812c-5065f38bc301")

trainee_attributes = {
  age_range: "3 to 11 programme", # "efa15e61-8ec0-e611-80be-00155d010316"
  subject: "Art and design", # "ee8274df-181e-e711-80c8-0050568902d3"
}

trainee = FactoryBot.create(:trainee, :with_programme_details, :diversity_disclosed, trainee_attributes)

degree_attributes = {
  subject: "Accountancy", # "ee8274df-181e-e711-80c8-0050568902d3"
  institution: "Aberystwyth University", # "443e2cff-6f42-e811-80ff-3863bb3640b8"
  grade: "First-class Honours", # "fe2fca5f-766d-e711-80d2-005056ac45bb"
  country: "Ireland",
}

trainee.degrees << FactoryBot.create(:degree, :non_uk_degree_with_details, degree_attributes)

entity_ids = Dttp::RegisterForTrn.call(trainee: Dttp::TraineePresenter.new(trainee: trainee), trainee_creator_dttp_id: user.dttp_id)
puts entity_ids

trainee.last_name = "oldsome"

trainee.programme_start_date = Time.zone.now.iso8601

result = Dttp::ContactUpdate.call(trainee: Dttp::TraineePresenter.new(trainee: trainee), trainee_creator_dttp_id: user.dttp_id)
puts(result)
trainee.destroy!
