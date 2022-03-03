# frozen_string_literal: true

FactoryBot.define do
  factory :dqt_trn_request, class: "Dqt::TrnRequest" do
    trainee
    request_id { SecureRandom.uuid }
    response { '{"requestId":"72888c5d-db14-4222-829b-7db9c2ec0dc3","status":"Completed","trn":"1234567"}' }
    state { 1 }
  end
end
