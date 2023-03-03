FactoryBot.define do
  factory :bulk_update_error, class: 'BulkUpdate::Error' do
    errored_on_id { "" }
    errored_on_type { "MyString" }
    message { "MyString" }
  end
end
