# frozen_string_literal: true

FactoryBot.define do
  factory :service_update, class: "ServiceUpdate" do
    title { "This is a title" }
    content { "_This_ is a **Markdown** content." }
    date { Time.zone.today }
  end
end
